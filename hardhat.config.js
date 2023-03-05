require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require('@nomiclabs/hardhat-etherscan');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    goerli: {
      url: "https://goerli.infura.io/v3/7edb90d1cdcb40f48c38c17568b5ea78",
      accounts: ["2456c9f1a9c026606cf97f754a6bd88c6a8d079fff99862a796d72c8f21ae44b"],
    },
    mainnet: {
      url: "https://mainnet.infura.io/v3/7edb90d1cdcb40f48c38c17568b5ea78",
      accounts: ["2456c9f1a9c026606cf97f754a6bd88c6a8d079fff99862a796d72c8f21ae44b"],
    },
  },
  etherscan: {
    apiKey: {
      goerli: "IUZA8RDY7YZHJ8E95CXG98217AXUCBA8EZ"
    }
  },
  solidity: {
    version: "0.8.13",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
