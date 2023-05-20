// deploy.js

async function main() {
  // Get the contract factory
  const MyContract = await ethers.getContractFactory('RacePermit');
  const drivrsFactory = await ethers.getContractFactory('Drivrs');

  const drivrsContract = await drivrsFactory.deploy();
  
  console.log("drivrs deployed to:", drivrsContract.address);

  // Deploy the contract
  //Drivrs Address
  const myContract = await upgrades.deployProxy(MyContract, [drivrsContract.address]);

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
