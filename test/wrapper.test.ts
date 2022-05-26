import chai, { expect } from "chai";
import { solidity } from "ethereum-waffle";
import { Contract, utils, ethers } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import { deploy } from "./deploy";

chai.use(solidity);

// ! THIS TEST ONLY RUN ON MAINNET FORK

describe("Wrapper Contract", () => {
  let owner: SignerWithAddress;
  let baycHolder: SignerWithAddress;
  let cpunksHolder: SignerWithAddress;
  let users: SignerWithAddress[];

  let wrapper: Contract;
  let cover: Contract;
  let bayc: Contract;
  let cpunks: Contract;

  const baycIds = [7808]
  const cpunkscIds = [8502]

  beforeEach("Deploy contracts", async () => {
    ({
      role: { owner, baycHolder, cpunksHolder, users },
      token: { bayc, cpunks },
      core: { wrapper, cover },
    } = await deploy());
    // transfer bayc and cpunks to owner
    await bayc.connect(baycHolder).transferFrom(baycHolder.address, owner.address, baycIds[0]);
    await cpunks.connect(cpunksHolder).transferPunk(owner.address, cpunkscIds[0]);

    // mint 1 cover for owner
    await cover.connect(owner).mint(0, {value: ethers.utils.parseEther("0.02")});
  });

  describe("Deployment", () => {
    it("Should set the right owner", async () => {
      expect(await wrapper.owner()).to.equal(owner.address);
    });
    it("Should set the right cover", async () => {
      expect(await wrapper.gallerierCover()).to.equal(cover.address);
    });
  });

  describe("Transactions", () => {
    beforeEach("Approve spend on wrapper contract", async () => {
      await bayc.connect(owner).approve(wrapper.address, baycIds[0]);
      await cover.connect(owner).setApprovalForAll(wrapper.address, true);
      // await cpunks.connect(owner).approve(wrapper.address, utils.parseEther("100"));
    });
    describe("Wrap", () => {
      it("Should be able to wrap nft", async () => {
        const _cover = {
          token: cover.address, 
          tokenId: 0
        };
        const _workpieces = [
          {
            token: bayc.address, 
            tokenId: baycIds[0]
          }
        ]

        // expect(
        //   await wrapper.connect(owner).wrap(_cover, _workpieces)
        // ).to.emit(wrapper, "Wrap")
      });
    });
  })
});
