// deployDrivrs.js

async function main() {
    // Get the contract factory
    const testContract = await ethers.getContractFactory('TEST');
   
    const myTestContract = await testContract.deploy(10000000000);

    console.log("myRacePermitContract deployed to:", myTestContract.address);


    
    await myTestContract.deployTransaction.wait(2);
    console.log(`Confirmed!`);
    await verify(myTestContract.address,[],"Test");
  }

  const verify = async (contractAddress, args,contractName) => {
    console.log("Verifying contract...");
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
            contract: `contracts/${contractName}.sol:${contractName}`
        });
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already verified!");
        } else {
            console.log(e);
        }
    }
};
  
  // Call the main function
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
  