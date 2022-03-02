// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

const localChainId = "31337";

// const sleep = (ms) =>
//   new Promise((r) =>
//     setTimeout(() => {
//       console.log(`waited for ${(ms / 1000).toFixed(3)} seconds`);
//       r();
//     }, ms)
//   );

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  await deploy("Messenger", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    // args: [ "Hello", ethers.utils.parseEther("1.5") ],
    log: true,
    waitConfirmations: 5,
  });

  // Getting a previously deployed contract
  const Messenger = await ethers.getContract("Messenger", deployer);
  const MessengerImage = await ethers.getContract("MessengerImage", deployer);
  await Messenger.setMetaAddress(MessengerImage.address).then((tx) => tx.wait());
  console.log("metaAddress set to:", await Messenger.metaAddress());
  await Messenger.mint("0xA7d7A55E943B877c39AB59566fb1296b10aA4d29", "Deployer guy was able to mint an NFT!").then((tx) => tx.wait());;
  const owner = await Messenger.ownerOf(0);
  console.log("Owner of the first minted NFT is:", owner);

  //const URI = await Messenger.tokenURI(0);
  /*  await Messenger.setPurpose("Hello");
  
    To take ownership of yourContract using the ownable library uncomment next line and add the 
    address you want to be the owner. 
   */

    //const yourContract = await ethers.getContractAt('Messenger', "0xaAC799eC2d00C013f1F11c37E654e59B0429DF6A") //<-- if you want to instantiate a version of a contract at a specific address!
  
    await Messenger.transferOwnership("0x6E95B5abFdf6e4e71162fA38d2F4f1b4F1f008f1");
    await MessengerImage.transferOwnership("0x6E95B5abFdf6e4e71162fA38d2F4f1b4F1f008f1");

 /*

  //If you want to send value to an address from the deployer
  const deployerWallet = ethers.provider.getSigner()
  await deployerWallet.sendTransaction({
    to: "0x34aA3F359A9D614239015126635CE7732c18fDF3",
    value: ethers.utils.parseEther("0.001")
  })
  */

  /*
  //If you want to send some ETH to a contract on deploy (make your constructor payable!)
  const yourContract = await deploy("Messenger", [], {
  value: ethers.utils.parseEther("0.05")
  });
  */

  /*
  //If you want to link a library into your contract:
  // reference: https://github.com/austintgriffith/scaffold-eth/blob/using-libraries-example/packages/hardhat/scripts/deploy.js#L19
  const yourContract = await deploy("Messenger", [], {}, {
   LibraryName: **LibraryAddress**
  });
  */

  // Verify from the command line by running `yarn verify`

  // You can also Verify your contracts with Etherscan here...
  // You don't want to verify on localhost
  // try {
  //   if (chainId !== localChainId) {
  //     await run("verify:verify", {
  //       address: Messenger.address,
  //       contract: "contracts/Messenger.sol:Messenger",
  //       contractArguments: [],
  //     });
  //   }
  // } catch (error) {
  //   console.error(error);
  // }
};
module.exports.tags = ["Messenger"];
