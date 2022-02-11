const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("My Dapp", function () {
  let myContract;

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });

  describe("YourContract", function () {
    it("Should deploy YourContract", async function () {
      const YourContract = await ethers.getContractFactory("YourContract");

      myContract = await YourContract.deploy();
    });

    describe("mint()", function () {
      it("Should be able to mint a new NFT", async function () {
        const newPurpose = "Hello World";
        const [owner] = await ethers.getSigners();

        expect(await myContract.totalSupply()).to.equal(0);

        await myContract.mint(owner.address, newPurpose);
        expect(await myContract.totalSupply()).to.equal(1);

        const URI = await myContract.tokenURI(1);

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
