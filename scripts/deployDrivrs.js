// deployDrivrs.js

async function main() {
    // Get the contract factory
    const echelonContract = await ethers.getContractFactory('TheEchelon');
    const racePermitContract = await ethers.getContractFactory('RacePermit');
    const vehiclsContract = await ethers.getContractFactory('Vehicls');
  
    // Deploy the contract
    // Drivrs Address
    const myEchelonContract = await echelonContract.deploy();
    const myRacePermitContract = await racePermitContract.deploy();
    const myVehiclsContract = await vehiclsContract.deploy();

  
    console.log("myEchelonContract deployed to:", myEchelonContract.address);

    console.log("myRacePermitContract deployed to:", myRacePermitContract.address);

    console.log("myVehiclsContract deployed to:", myVehiclsContract.address);

    console.log(`Waiting for blocks confirmations...`);
    await myEchelonContract.deployTransaction.wait(2);
    await myRacePermitContract.deployTransaction.wait(2);
    await myVehiclsContract.deployTransaction.wait(2);
    console.log(`Confirmed!`);
    await verify(myEchelonContract.address,[],"TheEchelon");
    await verify(myRacePermitContract.address,[],"RacePermit");
    await verify(myVehiclsContract.address,[],"Vehicls");
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
  