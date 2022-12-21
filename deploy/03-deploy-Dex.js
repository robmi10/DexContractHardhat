const { ethers } = require("hardhat");

const daiAmount = 2000000000000000000000n;
const ethAmount = 30000000000000000000n;
fromWei = ethers.utils.formatEther;

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  [owner, account2] = await ethers.getSigners();
  daiToken = await ethers.getContract("DAI", deployer);
  liquidityToken = await ethers.getContract("LiquidityToken", deployer);
  const Dex = await deploy("Dex", {
    from: deployer,
    args: [],
    log: true,
  });
  console.log("Deployed dex address at", Dex.address);
};

module.exports.tags = ["all", "Dex"];
