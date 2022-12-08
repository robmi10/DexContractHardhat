module.exports = async ({}) => {
  const deploy = deployments();
  const { deployer } = await getNamedAccounts();

  const WETHToken = await deploy("WETH", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log("Deployed weth address at", WETHToken.address);
  const transferEthToWeth = await deployer.sendTransaction({
    to: WETHToken.address,
    value: ethers.utils.parseEther("50.0"),
  });

  await transferEthToWeth.wait(1);
  console.log("Current WETH token balance", WETHToken.balanceOf());
};

module.exports.tags[("all", "WETHToken")];
