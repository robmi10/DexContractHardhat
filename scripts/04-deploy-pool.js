const { ethers } = require("hardhat");

// module.exports = async ({ getNamedAccounts, deployments }) => {
//   const { deploy } = deployments;
//   const { deployer } = await getNamedAccounts();
//   [owner, account2] = await ethers.getSigners();
//   daiToken = await ethers.getContract("DAI", deployer);
//   liquidityToken = await ethers.getContract("LiquidityToken", deployer);
//   console.log(
//     `\n
//           WethToken --> [${daiToken.address}]
//           LiquidityToken --> [${liquidityToken.address}]
//            \n`
//   );

//   await deploy("Pool", {
//     from: deployer,
//     args: [liquidityToken.address, daiToken.address],
//     log: true,
//   });
// };

// module.exports.tags = ["all", "Pool"];
