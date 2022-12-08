module.exports = async ({}) => {
  const deploy = deployments();
  const { deployer } = await getNamedAccounts();
  const daiAmount = 100e18;
  const wethAmount = 100e18;

  liquidityToken = await ethers.getContract("WETHToken");
  daiToken = await ethers.getContract("DaiToken");
  liquidityToken = await ethers.getContract("LiquidityToken");

  const Dex = await deploy("Dex", {
    from: deployer,
    args: [liquidityToken.address],
    log: true,
  });
  console.log("Deployed dex address at", Dex.address);

  //add first liquidity

  const addWethLiquidity = await Dex.addLiquidity(daiAmount, daiToken.address);

  const transferLiquidityWethToContract = await Dex.address.sendTransaction({
    to: WETHToken.address,
    value: ethers.utils.parseEther("80.0"),
  });

  await transferEthToWeth.wait(1);
  console.log("Current WETH token balance", WETHToken.balanceOf());

  await liquidityToken.connect(deployer).approve(dex.address, 50);
  const addLiquidityToDex = await deployer.sendTransaction({
    to: Dex.address,
    value: ethers.utils.parseEther("50.0"),
  });
};

module.exports.tags[("all", "Dex")];
