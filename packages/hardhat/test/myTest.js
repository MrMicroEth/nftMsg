const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");
let accounts
let message = "Hello World";
/*yarn chain, yarn deploy, yarn start*/

use(solidity);

describe("My Dapp", function () {
  let myContract;

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });
  
  beforeEach(async function() { 
    accounts = await ethers.getSigners();
  });
    
  describe("YourContract", function () {
    it("Should deploy YourContract", async function () {
      const YourContract = await ethers.getContractFactory("YourContract");

      myContract = await YourContract.deploy();
    });

    describe("mint()", function () {
      it("Should be able to mint a new NFT", async function () {

        expect(await myContract.balanceOf(accounts[1].address)).to.equal(0);

        await myContract.mint(accounts[1].address, message);
        expect(await myContract.balanceOf(accounts[1].address)).to.equal(1);
        const URI = await myContract.tokenURI(0);
      });

      it("Should be able to modify a users NFT", async function () {
        message = "Hello, I am interested in purchasing your punk #4358 for 1000Eth, please email me at me@royce.email, thanks";
        await myContract.mint(accounts[1].address, message);
        
        const newValue = (await myContract.addressToMessage(accounts[1].address)).value;
        expect(newValue).to.equal(message);

        const URI = await myContract.tokenURI(0);

      });

    });
    describe("transfer()", function () {
      it("Should be able to transfer NFT and update Message info", async function () {
        expect(await myContract.balanceOf(accounts[1].address)).to.equal(1);
        expect(await myContract.ownerOf(0)).to.equal(accounts[1].address);
        const transfer = await myContract.connect(accounts[1]).transferFrom(accounts[1].address, accounts[2].address, 0);
        //await myContract.transferFrom(accounts[1].address, accounts[2].address, 0);
        expect(await myContract.balanceOf(accounts[1].address)).to.equal(0);
        expect(await myContract.balanceOf(accounts[2].address)).to.equal(1);
        //expect the correct sender and message for account 2
        const newMsg = await myContract.addressToMessage(accounts[2].address);
        expect(newMsg.value).to.equal(message);
        expect(newMsg.sender).to.equal(accounts[1].address);
        
        const URI = await myContract.tokenURI(0);
      });
      // Uncomment the event and emit lines in YourContract.sol to make this test pass

      /*it("Should emit a SetPurpose event ", async function () {
        const [owner] = await ethers.getSigners();

        const newPurpose = "Another Test Purpose";

        expect(await myContract.setPurpose(newPurpose)).to.
          emit(myContract, "SetPurpose").
            withArgs(owner.address, newPurpose);
      });*/
    });
  });
});
