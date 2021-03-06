// contracts/BotMarket.sol
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract BotMarket is Context, ReentrancyGuard, ERC1155Holder, Pausable, Ownable {

    using SafeMath for uint256;

    // The accessory being sold
    IERC1155 private _accessory;

    // Address where funds are collected
    address payable private _wallet;

    mapping(uint256 => Accessory) public accessories;

    struct Accessory {
        bool isForSale;
        uint256 price;
    }

    event AccessoryListed (uint256 clazz, uint256 price);
    event AccessoryPurchased(address indexed purchaser, address indexed beneficiary, uint256 value);


    constructor (address payable wallet, IERC1155 accessory) {
        require(wallet != address(0), "wallet is the zero address");
        require(address(accessory) != address(0), "accessory is the zero address");

        _wallet = wallet;
        _accessory = accessory;
    }

    // /**
    //  * @dev fallback function ***DO NOT OVERRIDE***
    //  */
    receive () external payable {
        purchaseAccessory(_msgSender(), 1); // default to clazz 1
    }

    function getAccessory() public view returns (IERC1155) {
        return _accessory;
    }

    function getWallet() public view returns (address payable) {
        return _wallet;
    }

    function purchaseAccessory(address beneficiary, uint256 clazz) public whenNotPaused nonReentrant payable {
        uint256 price = accessories[clazz].price;
        uint256 payment = msg.value;
        bool isForSale = accessories[clazz].isForSale;

        _preValidatePurchase(beneficiary, payment, price, isForSale);

        _processPurchase(beneficiary, clazz);
        emit AccessoryPurchased(_msgSender(), beneficiary, price);
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

    function withdrawAll() public payable onlyOwner {
        require(_wallet.send(address(this).balance));
    }
}
