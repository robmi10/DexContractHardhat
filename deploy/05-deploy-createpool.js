module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  [owner, account2, account3] = await ethers.getSigners();

  Dex = await ethers.getContract("DexV3");

  const createPooL = await Dex.connect(owner).createPool(
    liquidityToken.address,
    daiToken.address
  );
  const deploycreatePooL = await createPooL.wait(1);

  console.log({
    deploycreatePooLEvent: deploycreatePooL.events[0].args._pooladdress,
  });
  const poolAddress = deploycreatePooL.events[0].args._pooladdress;
};

module.exports.tags = ["all", "Pool"];
