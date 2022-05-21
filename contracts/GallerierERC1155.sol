// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract GallerierERC1155 is ERC1155 {
    // TODO: config the starter time of sale 
    struct CoverCollection {
        string name;
        uint remaining;
        uint256 limit;
        uint256 price;
    }
    address public immutable owner;
    uint256 public length;
    mapping(uint256 => CoverCollection) public covers;

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        owner = msg.sender;
    }

    function withdraw() public onlyOwner  {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }

    function addCoverCollection(
        string memory _cover,
        uint256 _limit,
        uint256 _price
    ) public {
        covers[length] = CoverCollection(_cover, _limit, _limit, _price);
        length += 1;
    }

    function mint(uint256 tokenId) public payable {
        require(tokenId < length, "URI query for nonexistent token");

        CoverCollection memory cover = covers[tokenId];
        require(msg.value >= cover.price, "Ether value sent is not correct");
        require(cover.remaining > 0, "Purchase would exceed max supply");
        _mint(msg.sender, tokenId, 1, "");
        cover.remaining -= 1;
        covers[tokenId] = cover;
    }
}
