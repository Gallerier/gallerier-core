// import { expect } from "chai";
import { ethers } from "hardhat";

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const GallerierWrapper = await ethers.getContractFactory(
      "GallerierWrapper"
    );
    const gallerierWrapper = await GallerierWrapper.deploy();
    await gallerierWrapper.deployed();

    // expect(await gallerierWrapper.greet()).to.equal("Hello, world!");

    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // // wait until the transaction is mined
    // await setGreetingTx.wait();

    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
