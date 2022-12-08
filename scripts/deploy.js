const hre = require("hardhat");

async function main() {
  console.log("inside main deploy");
  await deployments.fixture(["all"]);
  daiToken = await ethers.getContract("DaiToken");
  wethToken = await ethers.getContract("DaoGovernance");
  liquidityToken = await ethers.getContract("LiquidityToken");
  dex = await ethers.getContract("Leader");

  console.log(
    `\n
     DaoToken deployed at address --> [${daiToken.address}]
     DaoGovernance deployed at address --> [${wethToken.address}]
     TimeLock deployed at address --> [${liquidityToken.address}]
     Leader deployed at address --> [${dex.address}]
     \n`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
