// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OmniverseNFT is ERC721, Ownable {
    mapping(uint256 => string) private tokenURIs;

    constructor() ERC721("OMNIVERSE-NFT", "OMNIVERSE-NFT") {

    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return tokenURIs[tokenId];
    }

    function mint(address to, uint256 tokenId, string calldata uri) external onlyOwner() {
        _mint(to, tokenId);
        tokenURIs[tokenId] = uri;
    }

    function burn(uint256 tokenId) external onlyOwner() {
        _burn(tokenId);
    }
}