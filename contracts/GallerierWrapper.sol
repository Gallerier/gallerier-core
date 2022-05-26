//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { GallerierERC721 } from "./GallerierERC721.sol";
import { TokenIdOnToken, IGallerierERC721 } from "./interfaces/IGallerierERC721.sol";

import "hardhat/console.sol";

contract GallerierWrapper is Ownable {
    address public gallerierCover;
    uint256 public length;

    address[] public galleriers;

    event Wrap(uint256 id, TokenIdOnToken cover, TokenIdOnToken[] workpieces);
    event Unwrap(uint256 id);

    // TODO: whitelist cover

    constructor(address _gallerierCover) {
        gallerierCover = _gallerierCover;
    }

    function setCover(address _gallerierCover) external onlyOwner {
        gallerierCover = _gallerierCover;
    }

    function galleryLength() external view returns (uint) {
        return galleriers.length;
    }

    function withdraw() external onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function wrap(
        TokenIdOnToken memory _cover,
        TokenIdOnToken[] memory _workpieces
    ) public returns(address gallerierERC721) {

        require(gallerierCover == _cover.token, "Invalid cover");

        GallerierERC721 gallerier = new GallerierERC721(
            address(this),
            msg.sender
        );
        galleriers.push(address(gallerier));

        IERC1155(_cover.token).safeTransferFrom(
            msg.sender,
            address(gallerier),
            _cover.tokenId,
            1,
            ""
        );

        for (uint256 i = 0; i < _workpieces.length; i++) {
            TokenIdOnToken memory workpiece = _workpieces[i];
            IERC721(workpiece.token).transferFrom(
                msg.sender,
                address(gallerier),
                workpiece.tokenId
            );
        }

        gallerier.gallerierMaking(_cover, _workpieces);
        gallerierERC721 = address(gallerier);

        emit Wrap(galleriers.length - 1, _cover, _workpieces);
    }

    function unwrap(uint256 id) public {
        IGallerierERC721(galleriers[id]).burn();
        emit Unwrap(id);
    }
}
