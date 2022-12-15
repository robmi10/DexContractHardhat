const { ethers } = require("hardhat");
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const amount = 300;

  const DaiToken = await deploy("DAI", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log("Deployed daitoken address at", DaiToken.address);
  const DAItokenSend = await ethers.getContract("DAI", deployer);
  console.log({ amount });
  const transferDaiToDeployer = await DAItokenSend.transfer(deployer, amount);
  await transferDaiToDeployer.wait(1);

  console.log({ transferDaiToDeployer });
  const DaiTokenBalance = await DAItokenSend.balanceOf(deployer);
  console.log("Deployer DaiToken balance", DaiTokenBalance);
};

module.exports.tags = ["all", "DaiToken"];
