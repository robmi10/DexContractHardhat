const hre = require("hardhat");
const { ethers, deployments, network } = require("hardhat");

async function main() {
  [owner] = await ethers.getSigners();
  const receiver = "0x1CBd3b2770909D4e10f157cABC84C7264073C9Ec";
  console.log("inside main deploy");
  await deployments.fixture(["all"]);
  daiToken = await ethers.getContract("DAI");

  const sendToUser = await await daiToken
    .connect(owner)
    .transfer(receiver, daiAmount);

  sendToUser.wait(1);
  console.log({ daiTokenAddress: daiToken.address });
  console.log(
    `\n
     Transfered Dai Token From [${owner}] To [${receiver}]
     \n`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
