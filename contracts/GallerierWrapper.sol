//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./GallerierERC721.sol";
import "./interfaces/IGallerierWrapper.sol";
import "./interfaces/IGallerierERC721.sol";

import "hardhat/console.sol";

contract GallerierWrapper is IGallerierWrapper {
    address public immutable admin;
    uint256 public length;
    mapping(uint256 => address) galleriers;
    address public immutable gallerierCover;
    // TODO: whitelist cover

    modifier onlyAdmin() {
        require(msg.sender == admin, "Ownable: caller is not the admin");
        _;
    }

    constructor(address _gallerierCover) {
        admin = msg.sender;
        gallerierCover = _gallerierCover;
    }

    function wrap(
        TokenIdOnToken memory _cover,
        TokenIdOnToken[] memory _workpices
    ) public returns(address gallerierERC721) {
        GallerierERC721 gallerier = new GallerierERC721(
            address(this),
            msg.sender
        );
        galleriers[length] = address(gallerier);
        length += 1;

        require(gallerierCover == _cover.token, "Not Gallerier's Cover");
        IERC1155(_cover.token).safeTransferFrom(
            msg.sender,
            address(gallerier),
            _cover.tokenId,
            1,
            ""
        );

        for (uint256 i = 0; i < _workpices.length; i++) {
            TokenIdOnToken memory workpice = _workpices[i];
            IERC721(workpice.token).transferFrom(
                msg.sender,
                address(gallerier),
                workpice.tokenId
            );
        }

        gallerier.gallerierMaking(_cover, _workpices);
        gallerierERC721 = address(gallerier);
    }

    function unwrap(uint256 id) public {
        IGallerierERC721(galleriers[id]).burn();
    }
}
