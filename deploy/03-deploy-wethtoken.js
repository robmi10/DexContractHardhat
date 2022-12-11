const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const WETHToken = await deploy("WETH", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log("Deployed weth address at", WETHToken.address);
};

module.exports.tags = ["all", "WETHToken"];
