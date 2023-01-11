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
      // allowUnlimitedContractSize: true,
    },
    localhost: {
      chainId: 31337,
      allowUnlimitedContractSize: true,
    },

    ganache: {
      url: "HTTP://127.0.0.1:7545",
      chainId: 1337,
      allowUnlimitedContractSize: true,
      accounts: [
        "0xd3f2d7afc8d315b02676eea488c8441b04de17c3cf0b7ce95f7066b6e9b5716a",
      ],
      //9ebab9311d5ba5fbb3d4216e11e4f4b08601bfaece8cfca16e7ee914ca4247ce
    },
  },
};
