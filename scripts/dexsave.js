const { ethers } = require("hardhat");

const daiAmount = 2000000000000000000000n;
const daiAmount2 = 30000000000000000000n;
const wethAmount = 30000000000000000000n;
const wethAmountSecond = 300000000000000000000n;
const wethAmountFromEth = 50000000000000000000n;
fromWei = ethers.utils.formatEther;

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const provider = ethers.provider;
  [owner, account2] = await ethers.getSigners();
  wethToken = await ethers.getContract("WETH", deployer);
  daiToken = await ethers.getContract("DAI", deployer);
  liquidityToken = await ethers.getContract("LiquidityToken", deployer);
  console.log(
    `\n
          WethToken --> [${daiToken.address}]
          DaiToken --> [${wethToken.address}]
          LiquidityToken --> [${liquidityToken.address}]
           \n`
  );
  const Dex = await deploy("Dex", {
    from: deployer,
    args: [liquidityToken.address, daiToken.address, wethToken.address],
    log: true,
  });
  console.log("Deployed dex address at", Dex.address);
  console.log({ account2: account2.address });
  console.log({ deployerfirst: deployer });

  await sendEthToWeth(deployer, wethToken.address);
  await sendDai(deployer);
  await addLiquidityFuncDai(Dex.address, deployer);
  await addDaiLiquidityWeth(Dex.address, deployer);
};

const sendDai = async (deployer) => {
  const [owner, account2, account3, account4, account5] =
    await ethers.getSigners();
  daiToken = await ethers.getContract("DAI", deployer);

  console.log(
    "deployer dai balance->",
    fromWei(await daiToken.balanceOf(deployer))
  );

  await daiToken.transfer(account2.address, daiAmount);

  await daiToken.transfer(account3.address, daiAmount2);

  await daiToken.transfer(account4.address, daiAmount2);

  await daiToken.transfer(account5.address, daiAmount2);

  // -------------------------------------------------------------

  // const DexDaiTokenBalance = await daiToken.balanceOf(Dex.address);
  // const DexWethTokenBalance = await wethToken.balanceOf(Dex.address);
  // console.log(" Dex Dai Token Balance", fromWei(DexDaiTokenBalance));
  // console.log(" Dex Weth Token Balance", fromWei(DexWethTokenBalance));

  // await daiToken.connect(account3).approve(Dex.address, daiAmount2);
  // const addLiquidityDai = await Dex.connect(account3).addLiquidity(
  //   daiAmount2,
  //   daiToken.address,
  //   wethToken.address,
  //   liquidityToken.address
  // );
  // await addLiquidityDai.wait(1);

  // await daiToken.connect(account4).approve(Dex.address, daiAmount2);
  // const addLiquidityDaiaccount4 = await Dex.connect(account4).addLiquidity(
  //   daiAmount2,
  //   daiToken.address,
  //   wethToken.address,
  //   liquidityToken.address
  // );
  // await addLiquidityDaiaccount4.wait(1);

  // await daiToken.connect(account5).approve(Dex.address, daiAmount2);
  // const addLiquidityDaiaccount5 = await Dex.connect(account5).addLiquidity(
  //   daiAmount2,
  //   daiToken.address,
  //   wethToken.address,
  //   liquidityToken.address
  // );
  // await addLiquidityDaiaccount5.wait(1);
};

const sendEthToWeth = async (deployer) => {
  const [owner, account2, account3, account4, account5] =
    await ethers.getSigners();
  const wethToken = await ethers.getContract("WETH", deployer);
  const transferEthToWeth = await account2.sendTransaction({
    to: wethToken.address,
    value: wethAmountFromEth,
  });
  await transferEthToWeth.wait(1);
  const transferEthToWethaccount3 = await account3.sendTransaction({
    to: wethToken.address,
    value: wethAmountFromEth,
  });
  await transferEthToWethaccount3.wait(1);
  const WETHBalance = await wethToken.balanceOf(account2.address);

  const transferEthToWethaccount4 = await account4.sendTransaction({
    to: wethToken.address,
    value: wethAmountFromEth,
  });
  await transferEthToWethaccount4.wait(1);
  const WETHBalanceaccount4 = await wethToken.balanceOf(account4.address);

  const transferEthToWethaccount5 = await account5.sendTransaction({
    to: wethToken.address,
    value: wethAmountFromEth,
  });
  await transferEthToWethaccount5.wait(1);
  const WETHBalanceaccount5 = await wethToken.balanceOf(account5.address);

  console.log("Current Eth balance of acc2 ->");
  console.log("Current WETH token balance acc3 ->", fromWei(WETHBalance));
  console.log(
    "Current WETH token balance acc4 ->",
    fromWei(WETHBalanceaccount4)
  );
  console.log(
    "Current WETH token balance acc5 ->",
    fromWei(WETHBalanceaccount5)
  );
};

const addLiquidityFuncDai = async (dexAddress, accounteDeployer) => {
  const [owner, account2] = await ethers.getSigners();
  console.log({ deployersecond: accounteDeployer });
  const Dex = await ethers.getContractAt("Dex", dexAddress);
  const daiToken = await ethers.getContract("DAI", accounteDeployer);
  const liquidityToken = await ethers.getContract(
    "LiquidityToken",
    accounteDeployer
  );
  await daiToken.approve(Dex.address, daiAmount);
  const addDaiLiquidity = await Dex.addLiquidity(daiAmount);
  await addDaiLiquidity.wait(1);

  const DexDaiTokenBalance = await daiToken.balanceOf(Dex.address);
  const DeployerDaiTokenBalanceAfter = await daiToken.balanceOf(
    accounteDeployer
  );

  console.log(
    "\nDeployer WETH Token Balance",
    fromWei(DeployerDaiTokenBalanceAfter)
  );
  console.log(" Dex Dai Token Balance", fromWei(DexDaiTokenBalance));
};

const addDaiLiquidityWeth = async (dexAddress, accounteDeployer) => {
  const [owner, account2, account3, account4, account5] =
    await ethers.getSigners();
  const Dex = await ethers.getContractAt("Dex", dexAddress);
  const wethToken = await ethers.getContract("WETH", accounteDeployer);

  await wethToken.connect(account2).approve(Dex.address, wethAmount);
  const addWethLiquidity = await Dex.connect(account2).addLiquidity(wethAmount);
  await addWethLiquidity.wait(1);

  const WETHBalanceAfterAddingLiquidity = await wethToken.balanceOf(
    account2.address
  );

  const WETHBalanceDexAfterAddingLiquidity = await wethToken.balanceOf(
    Dex.address
  );

  await wethToken.connect(account3).approve(Dex.address, wethAmountSecond);
  const addLiquidityWeth = await Dex.connect(account3).addLiquidity(
    wethAmountSecond
  );
  await addLiquidityWeth.wait(1);

  await wethToken.connect(account4).approve(Dex.address, wethAmountSecond);
  const addLiquidityWethaccount4 = await Dex.connect(account4).addLiquidity(
    wethAmountSecond
  );
  await addLiquidityWethaccount4.wait(1);

  await wethToken.connect(account5).approve(Dex.address, wethAmountSecond);
  const addLiquidityWethaccount5 = await Dex.connect(account5).addLiquidity(
    wethAmountSecond
  );
  await addLiquidityWethaccount5.wait(1);

  // -----------------------------------------

  const DexDaiTokenBalance = await daiToken.balanceOf(Dex.address);
  const DexWethTokenBalance = await wethToken.balanceOf(Dex.address);
  console.log("\nDex Dai Token Balance", fromWei(DexDaiTokenBalance));
  console.log(" Dex Weth Token Balance", fromWei(DexWethTokenBalance));
  console.log(" Amount Dai input", fromWei(daiAmount2));

  await daiToken.connect(account3).approve(Dex.address, daiAmount2);
  const addLiquidityDai = await Dex.connect(account3).addLiquidity(daiAmount2);
  await addLiquidityDai.wait(1);

  console.log(
    "\nAccount2 WETH Token Balance",
    fromWei(WETHBalanceAfterAddingLiquidity)
  );
  console.log(
    "Dex WETH Token Balance",
    fromWei(WETHBalanceDexAfterAddingLiquidity)
  );

  console.log(
    "\naccount3 Weth After Balance ->",
    fromWei(await wethToken.balanceOf(account3.address))
  );

  console.log(
    "\naccount4 Weth After Balance ->",
    fromWei(await wethToken.balanceOf(account4.address))
  );

  console.log(
    "\naccount5 Weth After Balance ->",
    fromWei(await wethToken.balanceOf(account5.address))
  );

  console.log(
    "Dex Weth After Balance ->",
    fromWei(await wethToken.balanceOf(Dex.address))
  );
};
module.exports.tags = ["all", "Dex"];
