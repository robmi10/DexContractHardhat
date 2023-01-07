const hre = require("hardhat");
const { ethers, deployments, network } = require("hardhat");

async function main() {
  [owner] = await ethers.getSigners();
  const receiver = "0x94c4acFdcB04A1A6dEE91376370927ebCC77616D";
  console.log("inside main deploy");
  await deployments.fixture(["all"]);
  daiToken = await ethers.getContract("DAI");

  const sendToUser = await await daiToken
    .connect(owner)
    .transfer(receiver, "8000000000000000000");

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
