// contracts/Market.sol
// SPDX-License-Identifier: MIT OR Apache-2.0
// https://dev.to/dabit3/building-scalable-full-stack-apps-on-ethereum-with-polygon-2cfb
pragma solidity ^0.8.2;

// import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

// contract BotMarket is ReentrancyGuard, ERC1155Receiver {
contract BotMarket is Context, ReentrancyGuard, ERC1155Holder, Pausable, Ownable {

    using SafeMath for uint256;

    // The accessory being sold
    IERC1155 private _accessory;

    // Address where funds are collected
    address payable private _wallet;

    mapping(uint256 => Accessory) private accessories;

    struct Accessory {
        bool isForSale;
        uint256 price;
    }

    event AccessoryListed (uint256 clazz, uint256 price);
    event AccessoryPurchased(address indexed purchaser, address indexed beneficiary, uint256 value);


    constructor (address payable wallet, IERC1155 accessory) {
        require(wallet != address(0), "BotMarket: wallet is the zero address");
        require(address(accessory) != address(0), "BotMarket: accessory is the zero address");

        _wallet = wallet;
        _accessory = accessory;
    }

    // /**
    //  * @dev fallback function ***DO NOT OVERRIDE***
    //  * Note that other contracts will transfer funds with a base gas stipend
    //  * of 2300, which is not enough to call purchaseAccessory. Consider calling
    //  * purchaseAccessory directly when purchasing accessories from a contract.
    //  */
    receive () external payable {
        purchaseAccessory(_msgSender(), 1); // default to clazz 1
    }

    // /**
    //  * @return the accessory being sold.
    //  */
    function getAccessory() public view returns (IERC1155) {
        return _accessory;
    }

    // /**
    //  * @return the address where funds are collected.
    //  */
    function getWallet() public view returns (address payable) {
        return _wallet;
    }

    function purchaseAccessory(address beneficiary, uint256 clazz) public nonReentrant whenNotPaused payable {
        uint256 price = accessories[clazz].price;
        uint256 payment = msg.value;
        bool isForSale = accessories[clazz].isForSale;

        _preValidatePurchase(beneficiary, payment, price, isForSale);

        _processPurchase(beneficiary, clazz);
        emit AccessoryPurchased(_msgSender(), beneficiary, price);

        _forwardFunds(price, payment);
    }

    function _preValidatePurchase(address beneficiary, uint256 payment, uint256 price, bool isForSale) internal view virtual {
        require(isForSale, "Crowdsale: this accessory is not for sale.");
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(payment >= price, "Crowdsale: payment must be correct amount for purchasing accessory.");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }

    function _deliverAccessory(address beneficiary, uint256 clazz) internal virtual {
        _accessory.safeTransferFrom(address(this), beneficiary, clazz, 1, "0x000");
    }

    function _processPurchase(address beneficiary, uint256 clazz) internal virtual {
        _deliverAccessory(beneficiary, clazz);
    }

    function _forwardFunds(uint256 price, uint256 payment) internal virtual {
        _wallet.transfer(price);
        if(payment > price) {
            address payable buyerAddressPayable = payable(msg.sender); // We need to make this conversion to be able to use transfer() function to transfer ethers
            buyerAddressPayable.transfer(payment - price);
        }
    }

    function listAccessory(uint256 clazz, uint256 price) public whenNotPaused onlyOwner {
        require(price > 0, "Price of accessory must be greater than 0");
        setAccessoryPrice(clazz, price);
        setAccessoryForSale(clazz, true);

        emit AccessoryListed(clazz, price);
    }

    function delistAccessory(uint256 clazz) public whenNotPaused onlyOwner {
        setAccessoryForSale(clazz, false);
    }

    function setAccessoryForSale(uint256 clazz, bool isForSale) public whenNotPaused onlyOwner {
        require(accessories[clazz].price > 0, "Price of accessory must be greater than 0");
        accessories[clazz].isForSale = isForSale;
    }

    function setAccessoryPrice(uint256 clazz, uint256 price) public whenNotPaused onlyOwner {
        accessories[clazz].price = price;
    }
}

// contract BotMarket is ReentrancyGuard {
//     using Counters for Counters.Counter;
//     Counters.Counter private _itemIds;
//     Counters.Counter private _itemsSold;

//     address payable owner;
//     uint256 listingPrice = 0.015 ether; // cost to list item

//     constructor() {
//         owner = payable(msg.sender);
//     }

//     struct MarketItem {
//         uint itemId;
//         address nftContract;
//         uint256 tokenId;
//         address payable seller;
//         address payable owner;
//         uint256 price;
//         bool sold;
//     }

//     mapping(uint256 => MarketItem) private idToMarketItem;

//     event MarketItemCreated (
//         uint indexed itemId,
//         address indexed nftContract,
//         uint256 indexed tokenId,
//         address seller,
//         address owner,
//         uint256 price,
//         bool sold
//     );

//     /* Returns the listing price of the contract */
//     function getListingPrice() public view returns (uint256) {
//         return listingPrice;
//     }

//     /* Places an item for sale on the marketplace */
//     function createMarketItem(
//         address nftContract,
//         uint256 tokenId,
//         uint256 price
//     ) public payable nonReentrant {
//         require(price > 0, "Price must be at least 1 wei");
//         require(msg.value == listingPrice, "Price must be equal to listing price");

//         _itemIds.increment();
//         uint256 itemId = _itemIds.current();

//         idToMarketItem[itemId] =  MarketItem(
//             itemId,
//             nftContract,
//             tokenId,
//             payable(msg.sender),
//             payable(address(0)), // zero address for contract
//             price,
//             false
//         );

//         IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

//         emit MarketItemCreated(
//             itemId,
//             nftContract,
//             tokenId,
//             msg.sender,
//             address(0),
//             price,
//             false
//         );
//     }

//     /* Creates the sale of a marketplace item */
//     /* Transfers ownership of the item, as well as funds between parties */
//     function createMarketSale(
//         address nftContract,
//         uint256 itemId
//     ) public payable nonReentrant {
//         uint price = idToMarketItem[itemId].price;
//         uint tokenId = idToMarketItem[itemId].tokenId;
//         require(msg.value == price, "Please submit the asking price in order to complete the purchase");

//         idToMarketItem[itemId].seller.transfer(msg.value);
//         IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
//         idToMarketItem[itemId].owner = payable(msg.sender);
//         idToMarketItem[itemId].sold = true;
//         _itemsSold.increment();
//         payable(owner).transfer(listingPrice);
//     }

//     /* Returns all unsold market items */
//     function fetchMarketItems() public view returns (MarketItem[] memory) {
//         uint itemCount = _itemIds.current();
//         uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
//         uint currentIndex = 0;

//         MarketItem[] memory items = new MarketItem[](unsoldItemCount);
//         for (uint i = 0; i < itemCount; i++) {
//             if (idToMarketItem[i + 1].owner == address(0)) {
//                 uint currentId = i + 1;
//                 MarketItem storage currentItem = idToMarketItem[currentId];
//                 items[currentIndex] = currentItem;
//                 currentIndex += 1;
//             }
//         }
//         return items;
//     }

//     /* Returns only items that a user has purchased */
//     function fetchMyNFTs() public view returns (MarketItem[] memory) {
//         uint totalItemCount = _itemIds.current();
//         uint itemCount = 0;
//         uint currentIndex = 0;

//         for (uint i = 0; i < totalItemCount; i++) {
//             if (idToMarketItem[i + 1].owner == msg.sender) {
//                 itemCount += 1;
//             }
//         }

//         MarketItem[] memory items = new MarketItem[](itemCount);
//         for (uint i = 0; i < totalItemCount; i++) {
//             if (idToMarketItem[i + 1].owner == msg.sender) {
//                 uint currentId = i + 1;
//                 MarketItem storage currentItem = idToMarketItem[currentId];
//                 items[currentIndex] = currentItem;
//                 currentIndex += 1;
//             }
//         }
//         return items;
//     }

//     /* Returns only items a user has created */
//     function fetchItemsCreated() public view returns (MarketItem[] memory) {
//         uint totalItemCount = _itemIds.current();
//         uint itemCount = 0;
//         uint currentIndex = 0;

//         for (uint i = 0; i < totalItemCount; i++) {
//             if (idToMarketItem[i + 1].seller == msg.sender) {
//                 itemCount += 1;
//             }
//         }

//         MarketItem[] memory items = new MarketItem[](itemCount);
//         for (uint i = 0; i < totalItemCount; i++) {
//             if (idToMarketItem[i + 1].seller == msg.sender) {
//                 uint currentId = i + 1;
//                 MarketItem storage currentItem = idToMarketItem[currentId];
//                 items[currentIndex] = currentItem;
//                 currentIndex += 1;
//             }
//         }
//         return items;
//     }
// }
