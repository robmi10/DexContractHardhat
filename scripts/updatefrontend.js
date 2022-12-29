const { ethers, network, config } = require("hardhat");
const fs = require("fs");
var fse = require("fs-extra");
var path = require("path");

require("dotenv/config");

const FRONT_END_ADDRESSED_FILE =
  "../dexfrontend/constants/contractAddresses.json";
const FRONT_END_ABI_FILE = "../dexfrontend/constants/abi.json";

var sourceDir = path.join(__dirname, "../deployments/localhost");
var destinationDir = path.join(__dirname, "../../dexfrontend/constants/");

console.log("update frontend!");

console.log("process.env.UPDATE_FRONT_END ->", process.env.UPDATE_FRONT_END);

async function main() {
  if (process.env.UPDATE_FRONT_END) {
    if (!fs.existsSync(destinationDir)) {
      fs.mkdirSync(destinationDir, { recursive: true });
    }
    fse.copy(sourceDir, destinationDir, function (err) {
      if (err) {
        console.error(err);
      } else {
        updateContractAdresses();
        console.log("success!");
      }
    });
  }

  // async function updateAbi() {
  //   await deployments.fixture(["all"]);
  //   const daiToken = await ethers.getContract("DAI");
  //   const liquidityToken = await ethers.getContract("LIToken");
  //   const dex = await ethers.getContract("Dex");

  //   const currentABI = [
  //     { daiToken: daiToken.interface.format(ethers.utils.FormatTypes.json) },
  //     {
  //       liquidityToken: liquidityToken.interface.format(
  //         ethers.utils.FormatTypes.json
  //       ),
  //     },
  //     {
  //       dex: dex.interface.format(ethers.utils.FormatTypes.json),
  //     },
  //   ];
  //   fs.writeFileSync(FRONT_END_ABI_FILE, JSON.stringify(currentABI));
  // }

  async function updateContractAdresses() {
    await deployments.fixture(["all"]);
    const daiToken = await ethers.getContract("DAI");
    const liquidityToken = await ethers.getContract("LIToken");
    const dex = await ethers.getContract("Dex");

    const chainId = network.config.chainId.toString();

    const accounts = config.networks.hardhat.accounts;
    const index = 0; // first wallet, increment for next wallets
    const wallet1 = ethers.Wallet.fromMnemonic(
      accounts.mnemonic,
      accounts.path + `/${index}`
    );

    const privateKey1 = wallet1.privateKey;

    console.log({ privateKey1 });
    const currentAddresses = JSON.parse(
      fs.readFileSync(FRONT_END_ADDRESSED_FILE, "utf8")
    );
    if (chainId in currentAddresses) {
      if (
        !currentAddresses[chainId].includes([
          daiToken.address,
          liquidityToken.address,
          dex.address,
        ])
      ) {
        currentAddresses[chainId].push([
          {
            daiToken: daiToken.address,
            liquidityToken: liquidityToken.address,
            dex: dex.address,
          },
        ]);
      }
    }
    {
      currentAddresses[chainId] = [
        {
          daiToken: daiToken.address,
          liquidityToken: liquidityToken.address,
          dex: dex.address,
        },
      ];
    }

    fs.writeFileSync(
      FRONT_END_ADDRESSED_FILE,
      JSON.stringify(currentAddresses)
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
