// deploy.js

async function main() {
  // Get the contract factory
  const MyContract = await ethers.getContractFactory('RacePermit');

  // Deploy the contract
  //Drivrs Address
  const myContract = await upgrades.deployProxy(MyContract, ["0x2B4B9457d6b7E7B3A814cffcaF6cFFF7ee9c3673"]);

  // Wait for the contract to be mined and initialized
  await myContract.deployed();

  // Log the address of the deployed contract
  console.log('MyContract deployed to:', myContract.address);
}

// Call the main function
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
