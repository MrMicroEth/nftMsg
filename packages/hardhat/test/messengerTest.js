const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");
let accounts
let message = "Hello, I am interested in purchasing your punk #4358 for 1000Eth, please email me at me@royce.email, thanks";
const longMessage = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Feugiat in fermentum posuere urna. Iaculis eu non diam phasellus vestibulum lorem. Lacinia quis vel eros donec ac odio tempor orci. Est ullamcorper eget nulla facilisi etiam dignissim diam quis enim. Dictum varius duis at consectetur lorem donec massa. Ipsum dolor sit amet consectetur adipiscing. Sed odio morbi quis commodo odio aenean sed. Aenean et tortor at risus. Vitae semper quis lectus nulla. Arcu odio ut sem nulla.";
/*yarn chain, yarn deploy, yarn start*/

use(solidity);

describe("My Dapp", function () {
  let messenger;

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });
  
  beforeEach(async function() { 
    accounts = await ethers.getSigners();
  });
    
  describe("Messenger", function () {
    it("Should deploy Messenger", async function () {
      const MessengerImage = await ethers.getContractFactory("MessengerImage");
      const Messenger = await ethers.getContractFactory("Messenger");

      const image = await MessengerImage.deploy();
      
      console.log(image.address);
      messenger = await Messenger.deploy();
      
      await messenger.setGenesisMetaAddress(image.address).then((tx) => tx.wait());
      console.log("genesisMetaAddress set to:", await messenger.genesisMetaAddress());
    });
//add test transfer and genesis theme
    describe("mint()", function () {

      it("Should revert with a long message", async function () {
        await expect(messenger.mint(accounts[1].address, longMessage)).to.be.revertedWith("String input exceeds message limit");
      });
      
      it("Should revert if user has opted out", async function () {
        //optOut
        await messenger.connect(accounts[1]).changeOptOut();
        await expect(messenger.mint(accounts[1].address, message)).to.be.revertedWith("User has opted out of receiving messasges");
        //opt-in
        await messenger.connect(accounts[1]).changeOptOut();
      });

      it("Should be able to mint a new NFT", async function () {
        expect(await messenger.balanceOf(accounts[1].address)).to.equal(0);
        await messenger.mint(accounts[1].address, message);
        expect(await messenger.balanceOf(accounts[1].address)).to.equal(1);
        expect(await messenger.tokenSupply()).to.equal(1);
      });

      it("Should revert if fee is below limit", async function () {
      //  await messenger.increaseThemeLimit(1);
        await messenger.updateFee(1);
        await expect(messenger.connect(accounts[2]).mint(accounts[1].address, message)).to.be.revertedWith("eth value is below expected fee");
      });
      
      it("Should be able to modify a users NFT", async function () {
        expect(await messenger.balanceOf(accounts[1].address)).to.equal(1);
        message = "new shorter message";
        await messenger.mint(accounts[1].address, message);
        
        expect(await messenger.tokenSupply()).to.equal(1);
        const newValue = (await messenger.addressToMessage(accounts[1].address)).value;
        expect(newValue).to.equal(message);
        expect(await messenger.balanceOf(accounts[1].address)).to.equal(1);
      });

      it("Should be able to mint with fee", async function () {
        await messenger.updateFee(ethers.utils.parseEther("2.0"));
        expect(ethers.utils.formatEther(await messenger.fee())).to.equal("2.0");
        await messenger.increaseThemeLimit(10);
        await messenger.connect(accounts[1]).mint(accounts[2].address, message, {
          value: ethers.utils.parseEther("2.0")
        });
        expect(await messenger.tokenSupply()).to.equal(2);
      });
    });

    describe("withdraw()", function () {

      it("non-owner withdrawl should fail", async function () {
        await expect(messenger.connect(accounts[1]).withdraw()).to.be.revertedWith("Ownable: caller is not the owner");
      });
      
      it("contract should be empty", async function () {
          const value = ethers.utils.formatEther(await  ethers.provider.getBalance(messenger.address));
          expect(value).to.equal("2.0");
          await messenger.withdraw();
          const newValue = ethers.utils.formatEther(await  ethers.provider.getBalance(messenger.address));
          expect(newValue).to.equal("0.0");
      });
      
      it("owner should be transfered funds", async function () {
          const value = ethers.utils.formatEther(await  ethers.provider.getBalance(accounts[0].address));
          expect(parseInt(value)).to.be.greaterThan(1000);//1000 is the starting balance, but gas costs lowers it some before withdraw
          console.log(parseInt(value));
      });

    });
  });
});
