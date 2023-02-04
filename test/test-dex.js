const { ethers, deployments, network } = require("hardhat");
const { expect } = require("chai");

describe("DexTest", async () => {
  let wethToken;
  let daiToken;
  let Dex;
  let owner;
  let addr1;
  let addr2;
  let poolAddress;
  const liquidityAmount = 4000000000000000000n;
  const SwapAmountInput = 1000000000000000000n;
  const SwapEstimatedInput = 1000000000000000000n;

  fromWei = ethers.utils.formatEther;
  beforeEach(async () => {
    await deployments.fixture(["all"]);
    [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();
    DaiToken = await ethers.getContract("DAI");
    Dex = await ethers.getContract("Dex");
  });

  it("swap", async () => {
    //create pool
    console.log({ DaiTokenAddr: DaiToken.address });

    const createPool = await Dex.createPool(DaiToken.address);

    const createPoolEvent = await createPool.wait(1);

    console.log({ createPoolEvent });

    const getLiquidityPool = await Dex.getPoolAddress(0);
    // await getLiquidityPool.wait(1);
    console.log({ getLiquidityPool });

    const approveDaiToken = await DaiToken.approve(
      getLiquidityPool,
      liquidityAmount
    );
    await approveDaiToken.wait(1);

    const addLiquidity = await Dex._addLiquidity(0, liquidityAmount, {
      value: ethers.utils.parseEther("4"),
    });
    const addLiquidityEvent = await addLiquidity.wait(1);
    console.log({ addLiquidityEvent });

    // await owner.sendTransaction({
    //   to: getLiquidityPool,
    //   value: ethers.utils.parseEther("2"),
    // });

    const getSwapEthToToken = await Dex._getSwapEthToToken(
      0,
      SwapEstimatedInput
    );

    const getSwapTokenToEth = await Dex._getSwapTokenToEth(
      0,
      SwapEstimatedInput,
      { value: ethers.utils.parseEther("1") }
    );

    const getSwapTokenToEthEvent = await getSwapTokenToEth.wait(1);

    console.log({
      getSwapTokenToEthEvent:
        getSwapTokenToEthEvent.events[1].args.outputamount.toString(),
    });

    const daiBalanceBefore = await DaiToken.balanceOf(owner.address);
    const ethalanceBefore = await ethers.provider.getBalance(owner.address);

    console.log({ daiBalanceBefore: daiBalanceBefore.toString() });
    console.log({ ethalanceBefore: ethalanceBefore.toString() });

    const approveSendDaiToken = await DaiToken.approve(
      getLiquidityPool,
      liquidityAmount
    );
    await approveSendDaiToken.wait(1);

    const swapEthToToken = await Dex._swapTokenToEth(
      0,
      getSwapTokenToEthEvent.events[1].args.outputamount.toString(),
      owner.address,
      {
        value: ethers.utils.parseEther("1"),
      }
    );
    const swapEthToTokenEvent = await swapEthToToken.wait(1);
    // console.log({ swapEthToTokenEvent });

    const daiBalanceAfter = await DaiToken.balanceOf(owner.address);
    const ethalanceAfter = await ethers.provider.getBalance(owner.address);

    console.log({ daiBalanceAfter: daiBalanceAfter.toString() });
    console.log({ ethalanceAfter: ethalanceAfter.toString() });

    console.log({
      daiBalanceDiff: Number(
        daiBalanceBefore.toString() - daiBalanceAfter.toString()
      ),
    });

    console.log({
      ethbalanceDiff: Number(
        ethalanceAfter.toString() - ethalanceBefore.toString()
      ),
    });
  });
});
