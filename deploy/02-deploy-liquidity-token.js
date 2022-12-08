const { ethers } = require("hardhat");

module.exports = async ({}) => {
  const deploy = deployments();
  const { deployer } = await getNamedAccounts();

  const VIVEToken = await deploy("VIVEToken", {
    from: deployer,
    args: [],
    log: true,
  });
  console.log("Deployed vivetoken address at", VIVEToken.address);
};

module.exports.tags[("all", "VIVEToken")];
