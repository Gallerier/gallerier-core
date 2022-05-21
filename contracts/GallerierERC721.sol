//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./interfaces/IGallerierERC721.sol";

import "hardhat/console.sol";

contract GallerierERC721 is ERC721, IGallerierERC721, IERC1155Receiver {
    uint256 private constant TOKEN_ID = 0;
    address public immutable gallerierWrapper;
    uint256 public piece;
    TokenIdOnToken public cover;
    mapping(uint256 => TokenIdOnToken) public workpices;

    modifier onlyGallerierWrapper() {
        require(
            msg.sender == gallerierWrapper,
            "GallerierERC721: burn caller is not gallerierWrapper"
        );
        _;
    }

    event UpdateGallerier(uint256 piece);

    constructor(address _gallerierWrapper, address to)
        ERC721("Gallerier book", "GLR")
    {
        _mint(to, TOKEN_ID);
        gallerierWrapper = _gallerierWrapper;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC1155).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function gallerierMaking(
        TokenIdOnToken memory _cover,
        TokenIdOnToken[] memory _workpices
    ) external override onlyGallerierWrapper {
        cover = _cover;
        this.updateGallerier(_workpices);
    }

    function updateGallerier(TokenIdOnToken[] memory _workpices)
        external
        override
    {
        for (uint256 i = 0; i < _workpices.length; i++) {
            TokenIdOnToken memory workpice = _workpices[i];
            require(
                IERC721(workpice.token).ownerOf(workpice.tokenId) ==
                    address(this),
                "GallerierERC721: not own the token"
            );
            workpices[i] = workpice;
        }
        piece = _workpices.length;
        emit UpdateGallerier(piece);
    }

    // TODO: add optional transfer to
    function burn() external override onlyGallerierWrapper {
        for (uint256 i = 0; i < piece; i++) {
            TokenIdOnToken memory workpice = workpices[i];
            IERC721(workpice.token).safeTransferFrom(
                address(this),
                ownerOf(TOKEN_ID),
                workpice.tokenId
            );
        }
        IERC1155(cover.token).safeTransferFrom(
            address(this),
            ownerOf(TOKEN_ID),
            cover.tokenId,
            1,
            ""
        );
        _burn(TOKEN_ID);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
