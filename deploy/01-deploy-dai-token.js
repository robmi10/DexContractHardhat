const { ethers } = require("hardhat");

module.exports = async ({}) => {
  const deploy = deployments();
  const { deployer } = await getNamedAccounts();

  const DaiToken = await deploy("DaiToken", {
    from: deployer,
    args: [],
    log: true,
  });
  console.log("Deployed daitoken address at", DaiToken.address);
};

module.exports.tags[("all", "DaiToken")];
