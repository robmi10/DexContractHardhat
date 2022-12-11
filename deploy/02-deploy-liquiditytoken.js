module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const LiquidityToken = await deploy("LiquidityToken", {
    from: deployer,
    args: [],
    log: true,
  });
  console.log("Deployed liquiditytoken address at", LiquidityToken.address);
};

module.exports.tags = ["all", "LiquidityToken"];
