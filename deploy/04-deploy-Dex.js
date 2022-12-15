const { ethers } = require("hardhat");

const daiAmount = 2000000000000000000000n;
const ethAmount = 30000000000000000000n;
fromWei = ethers.utils.formatEther;

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  [owner, account2] = await ethers.getSigners();
  daiToken = await ethers.getContract("DAI", deployer);
  liquidityToken = await ethers.getContract("LiquidityToken", deployer);

  console.log(
    `\n
          DaiToken --> [${daiToken.address}]
          LiquidityToken --> [${liquidityToken.address}]
           \n`
  );
  const Dex = await deploy("DexV3", {
    from: deployer,
    args: [],
    log: true,
  });
  console.log("Deployed dex address at", Dex.address);
  console.log({ account2: account2.address });
  console.log({ deployerfirst: deployer });

  // await createLiquidityPool(Dex.address, deployer);
};

const createLiquidityPool = async (dexAddress, deployer) => {
  const [owner, account2] = await ethers.getSigners();
  daiToken = await ethers.getContract("DAI", deployer);
  liquidityToken = await ethers.getContract("LiquidityToken", deployer);
  const Dex = await ethers.getContractAt("DexV3", account2.address);
  console.log({ deployer });

  console.log("createLiquidityPool -->");
  const createPooL = await Dex.connect(owner).createPool(
    liquidityToken.address,
    daiToken.address
  );
  const deploycreatePooL = await createPooL.wait(1);

  console.log({ deploycreatePooL });
};

module.exports.tags = ["all", "Dex"];
