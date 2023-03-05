const { ethers } = require("hardhat");

async function main() {
  // Get the address of the existing proxy contract
  const proxyAddress = "0x7df1b3ae827acc94af9805598e624b295f94672a";

  // Get the address of the owner of the existing contract
  const existingContractOwner = "0xaF213E546fF026f5e048bD71513247eC113fC60a";

  // Get the contract factory for the new implementation
  const NewImplementation = await ethers.getContractFactory("RacePermit");

  // Deploy the new contract
  const newContract = await NewImplementation.deploy();

  // Transfer ownership of the new contract to the existing owner
  await newContract.transferOwnership(existingContractOwner);

  // Get the proxy contract instance
  const Proxy = await ethers.getContractFactory("YourProxyContract");
  const proxyContract = await Proxy.attach(proxyAddress);

  // Upgrade the proxy contract to use the new implementation
  await proxyContract.connect(proxyAdmin).upgradeTo(newContract.address);

  console.log("Proxy upgraded to address:", newContract.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
