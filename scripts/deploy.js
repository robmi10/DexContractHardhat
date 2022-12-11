const hre = require("hardhat");
const { ethers, deployments, network } = require("hardhat");

async function main() {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const daiAmount = 100e18;
  const wethAmount = 50e18;
  console.log("inside main deploy");
  await deployments.fixture(["all"]);
  daiToken = await ethers.getContract("DAI");
  wethToken = await ethers.getContract("WETH");
  liquidityToken = await ethers.getContract("LiquidityToken");

  console.log(
    `\n
     DaiToken deployed at address --> [${daiToken.address}]
     WETHToken deployed at address --> [${wethToken.address}]
     LiquidityToken deployed at address --> [${liquidityToken.address}]
     \n`
  );

  // const Dex = await deploy("Dex", {
  //   from: deployer,
  //   args: [liquidityToken.address],
  //   log: true,
  // });
  // console.log("Deployed dex address at", Dex.address);

  // const addDaiLiquidity = await Dex.addLiquidity(
  //   daiAmount,
  //   daiToken.address,
  //   wethToken.address,
  //   liquidityToken.address
  // );
  // await addDaiLiquidity.wait(1);
  // console.log(
  //   "Dex added DAI liquidity to contract",
  //   daiToken.balanceOf(Dex.address)
  // );

  // const addWethLiquidity = await Dex.addLiquidity(
  //   wethAmount,
  //   wethToken.address,
  //   daiToken.address,
  //   liquidityToken.address
  // );
  // await addWethLiquidity.wait(1);
  // console.log(
  //   "Dex added DEX liquidity to contract",
  //   wethToken.balanceOf(Dex.address)
  // );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
