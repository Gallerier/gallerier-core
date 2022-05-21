//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

struct TokenIdOnToken {
    address token;
    uint256 tokenId;
}

interface IGallerierERC721 is IERC721 {
    function gallerierMaking(
        TokenIdOnToken memory _cover,
        TokenIdOnToken[] memory _workpices
    ) external;

    function updateGallerier(TokenIdOnToken[] memory _workpices) external;

    function burn() external;
}
