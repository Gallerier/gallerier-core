import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { ethers, network } from "hardhat";

export type Role = {
  owner: SignerWithAddress;
  baycHolder: SignerWithAddress;
  cpunksHolder: SignerWithAddress;
  users: SignerWithAddress[];
};

export type Token = {
  bayc: Contract;
  cpunks: Contract;
};

export type Core = {
  wrapper: Contract;
  cover: Contract;
};

export async function deploy(): Promise<{
  role: Role;
  token: Token;
  core: Core;
}> {
  await network.provider.request({
    method: "hardhat_impersonateAccount",
    params: ["0x8BBc693D042cEA740e4ff01D7E0Efb36110c36BF"],
  });
  await network.provider.request({
    method: "hardhat_impersonateAccount",
    params: ["0x26f744711ee9e5079CbEaF318ba8a8e938844de6"],
  });
  const baycHolder = await ethers.getSigner(
    "0x8BBc693D042cEA740e4ff01D7E0Efb36110c36BF"
  );
  const cpunksHolder = await ethers.getSigner(
    "0x26f744711ee9e5079CbEaF318ba8a8e938844de6"
  );

  const users = (await ethers.getSigners()).slice(0, 10);
  const owner = users[0];

  const _amount = ethers.utils.parseEther("1000");

  // Mint 1000 ETH to owner
  await network.provider.send("hardhat_setBalance", [
    owner.address,
    ethers.utils.hexlify(_amount),
  ]);
  // Mint 1000 ETH to baycHolder
  await network.provider.send("hardhat_setBalance", [
    baycHolder.address,
    ethers.utils.hexlify(_amount),
  ]);
  // Mint 1000 ETH to cpunksHolder
  await network.provider.send("hardhat_setBalance", [
    cpunksHolder.address,
    ethers.utils.hexlify(_amount),
  ]);

  const bayc = await ethers.getContractAt(
    "BoredApeYachtClub",
    "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D"
  );

  const cpunks = await ethers.getContractAt(
    "CryptoPunksMarket",
    "0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB"
  );

  // Deploy cover token
  const GallerierERC1155 = await ethers.getContractFactory("GallerierERC1155");
  const cover = await GallerierERC1155.connect(owner).deploy();

  const _name = "common";
  const _limit = 100;
  const _price = ethers.utils.parseEther("0.02");
  await cover.addCoverCollection(_name, _limit, _price)

  // Deploy wrapper
  const GallerierWrapper = await ethers.getContractFactory("GallerierWrapper");
  const wrapper = await GallerierWrapper.connect(owner).deploy(cover.address);

  return {
    role: { owner, baycHolder, cpunksHolder, users },
    token: { bayc, cpunks },
    core: { wrapper, cover },
  };
}
