// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  // Deploy cover token
  const GallerierERC1155 = await ethers.getContractFactory("GallerierERC1155");
  const cover = await GallerierERC1155.deploy();

  await cover.deployed();

  console.log("GallerierCover deployed to:", cover.address);

  const _name = "common";
  const _limit = 100;
  const _price = ethers.utils.parseEther("0.02");
  await cover.addCoverCollection(_name, _limit, _price)

  // Deploy wrapper
  const GallerierWrapper = await ethers.getContractFactory("GallerierWrapper");
  const wrapper = await GallerierWrapper.deploy(cover.address);

  await wrapper.deployed();

  console.log("GallerierWrapper deployed to:", wrapper.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
