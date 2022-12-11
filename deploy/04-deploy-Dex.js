const { ethers } = require("hardhat");

const daiAmount = 2000000000000000000000n;
const wethAmount = 50000000000000000000n;
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
    args: [liquidityToken.address],
    log: true,
  });
  console.log("Deployed dex address at", Dex.address);
  console.log({ account2: account2.address });
  console.log({ deployerfirst: deployer });

  await sendEthToWeth(deployer, wethToken.address);
  await addLiquidityFuncDai(Dex.address, deployer);
  await addDaiLiquidityWeth(Dex.address, deployer);
};

const sendEthToWeth = async (deployer) => {
  const [owner, account2] = await ethers.getSigners();
  const wethToken = await ethers.getContract("WETH", deployer);
  const transferEthToWeth = await account2.sendTransaction({
    to: wethToken.address,
    value: wethAmount,
  });
  await transferEthToWeth.wait(1);
  const WETHBalance = await wethToken.balanceOf(account2.address);
  console.log("Current Eth balance of acc2 ->");
  console.log("Current WETH token balance", fromWei(WETHBalance));
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
  const addDaiLiquidity = await Dex.addLiquidity(
    daiAmount,
    daiToken.address,
    wethToken.address,
    liquidityToken.address
  );
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
  const [owner, account2] = await ethers.getSigners();
  const Dex = await ethers.getContractAt("Dex", dexAddress);
  const wethToken = await ethers.getContract("WETH", accounteDeployer);

  await wethToken.connect(account2).approve(Dex.address, wethAmount);
  const addWethLiquidity = await Dex.connect(account2).addLiquidity(
    wethAmount,
    wethToken.address,
    daiToken.address,
    liquidityToken.address
  );
  await addWethLiquidity.wait(1);

  const WETHBalanceAfterAddingLiquidity = await wethToken.balanceOf(
    account2.address
  );
  const WETHBalanceDexAfterAddingLiquidity = await wethToken.balanceOf(
    Dex.address
  );

  console.log(
    "\nAccount2 WETH Token Balance",
    fromWei(WETHBalanceAfterAddingLiquidity)
  );
  console.log(
    "Dex WETH Token Balance",
    fromWei(WETHBalanceDexAfterAddingLiquidity)
  );
};
module.exports.tags = ["all", "Dex"];
