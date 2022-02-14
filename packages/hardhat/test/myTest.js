const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");
let accounts
let message = "Hello World";

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

        expect(await myContract.balanceOf(accounts[0].address)).to.equal(0);

        await myContract.mint(accounts[0].address, message);
        expect(await myContract.balanceOf(accounts[0].address)).to.equal(1);
        const URI = await myContract.tokenURI(0);
      });

      it("Should be able to modify a users NFT", async function () {
        message = "modded";
        await myContract.mint(accounts[0].address, message);
        
        const newValue = (await myContract.addressToMessage(accounts[0].address)).value;
        expect(newValue).to.equal(message);

        const URI = await myContract.tokenURI(0);

      });

    });
    describe("transfer()", function () {
      it("Should be able to transfer NFT", async function () {
        expect(await myContract.balanceOf(accounts[0].address)).to.equal(1);
        expect(await myContract.ownerOf(0)).to.equal(accounts[0].address);
        await myContract.transferFrom(accounts[0].address, accounts[1].address, 0);
        expect(await myContract.balanceOf(accounts[0].address)).to.equal(0);
        expect(await myContract.balanceOf(accounts[1].address)).to.equal(1);
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
