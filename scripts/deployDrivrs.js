// deployDrivrs.js

async function main() {
    // Get the contract factory
    const MyContract = await ethers.getContractFactory('Drivrs');
  
    // Deploy the contract
    //Drivrs Address
    const myContract = await MyContract.deploy();
  
    console.log("MyContract deployed to:", myContract.address);
  }
  
  // Call the main function
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
  