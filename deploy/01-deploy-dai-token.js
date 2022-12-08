module.exports = async ({}) => {
  const deploy = deployments();
  const { deployer } = await getNamedAccounts();
  const amount = 500e18;

  const DaiToken = await deploy("DaiToken", {
    from: deployer,
    args: [],
    log: true,
  });
  console.log("Deployed daitoken address at", DaiToken.address);

  const transferDaiToDeployer = await DaiToken.transfer(deployer, amount);
  await transferDaiToDeployer.wait(1);

  console.log("Deployer DaiToken balance", DaiToken.balanceOf(deployer));
};

module.exports.tags[("all", "DaiToken")];
