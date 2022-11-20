// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

//@dev Contracts for minting NFTs with 2 options
//@dev Owner of the minted NFT could be the msg.sender or a 3rd address

contract NFTContract is ERC721, ERC721Enumerable, Ownable, ERC721URIStorage, ERC721Royalty {

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    //@dev Minting NFT being the msg.sender the owner
    function _mint(string memory _tokenURI, uint96 _feeNumerator) public onlyOwner returns(uint256) {
        uint256 _tokenID = totalSupply();
        _mint(msg.sender, _tokenID);
        _setTokenURI(_tokenID, _tokenURI);
        _setTokenRoyalty(_tokenID, msg.sender, _feeNumerator);
        return _tokenID;
    }

    //@dev Minting NFT to another address (not msg.sender).
    //@dev Need to approve the msg.sender to manage this NFT
    function _mint(string memory _tokenURI, uint96 _feeNumerator, address _to) public onlyOwner returns(uint256) {
        uint256 _tokenID = totalSupply();
        _mint(_to, _tokenID);
        _setTokenURI(_tokenID, _tokenURI);
        _setTokenRoyalty(_tokenID, msg.sender, _feeNumerator);
        _setApprovalForAll(_to, msg.sender, true);
        return _tokenID;
    }

    // The following functions are overrides required by Solidity.


    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage, ERC721Royalty) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


}
