// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721Token.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//Tiene que tener una funcion para poder MINTEAR desde el otro contrato (con o sin address de owner)
// Mapping con los precios de cada NFT
// FUncion para SET PRICE / GET PRICE (Si seteas precio en 0, no está a la venta)
// Funcion de BUY NFT (esta es payable)
// Funcion de Withdraw para el owner de la galería

contract ArtGallery is ERC721, Ownable {
    // Initial Statements

    NFTContract public NFTContractTokenInstance;

    // Smart Contract Constructor
    constructor(string memory _tokenName, string memory _tokenSymbol)
        ERC721(_tokenName, _tokenSymbol)
    {
        NFTContractTokenInstance = new NFTContract("Malba Gallery", "MBG");
    }

    // Declaration of an event
    // Declarar los eventos de venta // compra // withdraw
    // Evento de pago de regalía al owner?

    event mintNFTEvent(address _owner, uint256 _tokenID);
    event sellEvent(address indexed _buyer, uint256 _price, uint256 _NFT);
    event royaltyPayedEvent(uint256 _royalty, address _royaltyReceiver);
    event withdrawEvent(uint256 _amount, uint256 _timestamp);

    //Mapping de Prices
    mapping(uint256 => uint256) _NFTPrices;

    //Function to publish a new NFT
    //@dev Mints a new NFT (2 functions. Owner could be the gallery or a 3rd address)

    //Publishing when owner is a 3rd address
    function _publishNFT(
        string memory _tokenURI,
        uint256 _tokenPrice,
        address to,
        uint96 _feeNumerator
    ) public onlyOwner {
        uint256 _newTokenId = NFTContractTokenInstance._mint(
            _tokenURI,
            _feeNumerator,
            to
        );
        _NFTPrices[_newTokenId] = _tokenPrice;

        emit mintNFTEvent(to, _newTokenId);
    }

    //Publishing when gallery is the owner of the NFT
    function _publishNFTGallery(
        string memory _tokenURI,
        uint256 _tokenPrice,
        uint96 _feeNumerator
    ) public onlyOwner {
        uint256 _newTokenId = NFTContractTokenInstance._mint(
            _tokenURI,
            _feeNumerator
        );
        _NFTPrices[_newTokenId] = _tokenPrice;
        emit mintNFTEvent(address(this), _newTokenId);
    }

    // NFT Token Price Update
    //@user If price set is 0, NFT will not be on sale
    function _setPrice(uint256 _tokenID, uint256 _newPrice) public {
        require(
            NFTContractTokenInstance.ownerOf(_tokenID) == msg.sender,
            "Not your NFT"
        );
        _NFTPrices[_tokenID] = _newPrice;
    }

    // Pricing of NFT Tokens (price of the artwork)

    function _getPrice(uint256 _tokenID)
        public
        view
        returns (uint256 _NFTPrice)
    {
        _NFTPrice = _NFTPrices[_tokenID];
    }

    // Obtaining all created NFT tokens (artwork)
    // Tiene que devolver todos los NFT que tiene la galeria ? EL numero de NFTS?
    function _artGalleryNFTBalance() public view onlyOwner returns (uint256) {
        uint256 _ArtGalleryNFTS = balanceOf(address(this));
        return _ArtGalleryNFTS;
    }

    // Obtaining a user's NFT tokens
    // Metodo balanceOf ?
    function _userNFTBalance(address _userAddress)
        public
        view
        returns (uint256)
    {
        uint256 _userNFTS = balanceOf(_userAddress);
        return _userNFTS;
    }

    // NFT Token Payment
    // La funcion de venta en sí. Que un msg.sender compre el NFT (es payable esta funcion seguramente)
    // Requeire que envie el monto adecuado
    // Requiere que la galeria sea el owner del NFT obviamente
    // Emite evento de venta
    function _BuyNFT(uint256 _tokenID) public payable {
        uint256 _tokenPrice = _NFTPrices[_tokenID];
        require(_tokenPrice > 0, "This NFT is not for sale");
        require(
            _tokenPrice == msg.value,
            "You didnt send the correct NFT Price"
        );

        address buyer = msg.sender;
        address seller = NFTContractTokenInstance.ownerOf(_tokenID);
        uint256 amountReceived = msg.value;

        NFTContractTokenInstance.safeTransferFrom(seller, buyer, _tokenID);

        //@dev Gets royalty for seller

        (, uint256 royaltyAmount) = NFTContractTokenInstance.royaltyInfo(_tokenID, _tokenPrice);
        uint256 sellerAmount = amountReceived - royaltyAmount;

        if (seller != address(this)) {
            payable(seller).transfer(sellerAmount);
        }

        _NFTPrices[_tokenID] = 0; //Mark token no longer for sale

        emit sellEvent(msg.sender, msg.value, _tokenID);
    }

    // Visualize the balance of the Smart Contract (ethers)
    function _ethContractBalance() public view onlyOwner returns (uint256) {
        uint256 _balance = address(this).balance;
        return _balance;
    }

    // Extraction of ethers from the Smart Contract to the Owner
    // Requiere que haya saldo sino no hay qué retirar
    function withdraw() external onlyOwner {
        uint _ethBalance = _ethContractBalance();
        require(address(this).balance > 0, "No ethers to withdraw");
        payable(msg.sender).transfer(_ethBalance);
        emit withdrawEvent(_ethBalance, block.timestamp);
    }
}
