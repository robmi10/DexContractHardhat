require("@nomicfoundation/hardhat-toolbox");

require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers");
require("@typechain/hardhat");
/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  // abiExporter: {
  //   path: "./abi",
  //   runOnCompile: true,
  //   clear: false,
  //   flat: true,
  // },
  solidity: {
    version: "0.8.8",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "hardhat",
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  networks: {
    hardhat: {
      chainId: 31337,
    },
    localhost: {
      chainId: 31337,
      allowUnlimitedContractSize: true,
    },

    polygon: {
      url: process.env.API_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      allowUnlimitedContractSize: true,
    },

    ganache: {
      url: "HTTP://127.0.0.1:7545",
      chainId: 1337,
      allowUnlimitedContractSize: true,
      accounts: [
        "0xdf7b327a71f8282bcdee3f2c8cc05859c229a8e2042485a8bc1c8bb637f17073",
      ],
    },
  },
};
