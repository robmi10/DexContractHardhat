const hre = require("hardhat");
const { ethers, deployments, network } = require("hardhat");

async function main() {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("inside main deploy");
  await deployments.fixture(["all"]);
  daiToken = await ethers.getContract("DAI");
  liquidityToken = await ethers.getContract("LiquidityToken");
  dex = await ethers.getContract("Dex");

  console.log(
    `\n
     DaiToken deployed at address --> [${daiToken.address}]
     LiquidityToken deployed at address --> [${liquidityToken.address}]
     DEX deployed at address --> [${dex.address}]
     \n`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
