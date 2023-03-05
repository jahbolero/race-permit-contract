// upgrade.js

const { ethers, upgrades } = require('hardhat');

async function main() {
  // Get the address of the existing contract
  const existingAddress = '0x7df1b3ae827acc94af9805598e624b295f94672a'; // replace with the actual address of the contract

  // Get the contract factory for the upgraded version
  const upgradedFactory = await ethers.getContractFactory('RacePermit');

  // Upgrade the contract
  const upgradedContract = await upgrades.upgradeProxy(existingAddress, upgradedFactory,["0xc2e0b447265883ec9d4b549611B4B9a54B727D25"]);

  // Wait for the contract to be mined and initialized
  await upgradedContract.deployed();

  // Log the address of the upgraded contract
  console.log('MyContract upgraded to:', upgradedContract.address);
}

// Call the main function
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
