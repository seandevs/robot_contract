// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Accessory is ERC1155, Ownable, Pausable, ERC1155Burnable {
    uint256 private SALETIME = 1634451621; // 7PM EDT on November 1st
    uint256 private PRICE = .08 ether; // .08 eth
    uint256 public constant CLASS_LAZER = 1;
    uint256 public constant CLASS_SWORD = 2;
    uint256 public constant CLASS_SAW = 3;
    uint256 public constant CLASS_WRENCH = 4;


    constructor(uint256[] memory _clazzes, uint256[] memory _amounts) ERC1155("https://gateway.pinata.cloud/ipfs/Qmf8pKSC5mV6nTVSR3shJQp9e7CgVrNqKG98ZCKuMmPBPm/metadata/api/item/{id}.json") {
        mintBatchAccessories(_clazzes, _amounts, "0x000");
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mintAccessory(uint256 _clazz, bytes memory _data) public whenNotPaused onlyOwner {
        require(_clazz > 0 &&  _clazz <= 4, "Accessory does not exist.");
        _mint(msg.sender, _clazz, 1, _data);
    }

    function mintBatchAccessories(uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data) public whenNotPaused onlyOwner {
        uint256 _idsLength = _ids.length;
        for (uint256 i=0; i<_idsLength; i++) {
            require(_ids[i] > 0 && _ids[i] <= 4, "Accessory does not exist.");
        }
        _mintBatch(msg.sender, _ids, _amounts, _data);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal whenNotPaused override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

}

