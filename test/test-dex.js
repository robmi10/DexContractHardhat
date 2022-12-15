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
  const daiAmount = 2000000000000000000000n;
  const daiSecondAmount = 4000000000000000000000n;
  const ethAmount = 30000000000000000000n;

  fromWei = ethers.utils.formatEther;
  beforeEach(async () => {
    await deployments.fixture(["all"]);
    [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();
    daiToken = await ethers.getContract("DAI");
    Dex = await ethers.getContract("DexV3");
    liquidityToken = await ethers.getContract("LiquidityToken");

    const createPooL = await Dex.connect(owner).createPool(
      liquidityToken.address,
      daiToken.address
    );
    const deploycreatePooL = await createPooL.wait(1);
    poolAddress = deploycreatePooL.events[0].args._pooladdress;
    console.log({ poolAddressInTest: poolAddress });
    const PoolDaiBalanceBeforeLiquidity = fromWei(
      await daiToken.balanceOf(poolAddress)
    );
    console.log({ PoolDaiBalanceBeforeLiquidity });

    //send token to add2
  });
  it("addLiquidity", async () => {
    // add liquidity from owner

    // await daiToken.connect(owner).approve(addr2.address, daiSecondAmount);

    // await daiToken.transferFrom(owner.address, addr2.address, daiSecondAmount);
    await daiToken.transfer(addr2.address, daiSecondAmount);
    console.log(
      "daiToken amount",
      fromWei(await daiToken.balanceOf(addr2.address))
    );

    console.log("poolAddress", poolAddress);
    const PoolA = await ethers.getContractAt("Pool", poolAddress);

    console.log({ PoolA: PoolA.address });
    console.log({ poolAddress });
    // await daiToken.approve(owner.address, daiAmount);
    // const getPooL = await Dex.getPoolAddress(0);
    // const deploygetPooL = await getPooL.wait(1);
    // const poolAddressDeployed = deploygetPooL.events[0].args._pooladdress;
    // console.log({ poolAddressDeployed });

    // const PoolAddress = await ethers.getContractAt("Pool", poolAddressDeployed);

    // console.log({ PoolAddress: PoolAddress.address });

    // await daiToken.connect(owner).approve(PoolAddress.address, daiAmount);
    const addLiquiditPooL = await Dex.connect(owner).getPoolAddress(0);
    const deployaddLiquiditPooL = await addLiquiditPooL.wait(1);
    const PoolAddress = deployaddLiquiditPooL.events[0].args._pooladdress;

    const approve = await daiToken
      .connect(owner)
      .approve(PoolA.address, daiAmount);
    await approve.wait(1);
    const addLiquiditPooLNow = await Dex.connect(owner)._addLiquidity(
      0,
      daiAmount
    );
    const deployaddLiquiditPooLNow = await addLiquiditPooLNow.wait(1);

    console.log({
      deployaddLiquiditPooLNow:
        deployaddLiquiditPooLNow.events[0].args._pooladdress,
    });

    // const PoolDaiBalanceAfterLiquidity = fromWei(
    //   await daiToken.balanceOf(poolAddress)
    // );

    // const DexDaiBalanceAfterLiquidity = fromWei(
    //   await daiToken.balanceOf(Dex.address)
    // );

    // console.log({ PoolDaiBalanceAfterLiquidity });

    // console.log({ DexDaiBalanceAfterLiquidity });

    expect(1).to.equal(80);
  });
});
