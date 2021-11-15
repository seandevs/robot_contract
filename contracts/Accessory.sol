// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract Accessory is ERC1155, Ownable, Pausable, ERC1155Burnable {
    uint256 public constant CLASS_BUZZSAW = 1;
    uint256 public constant CLASS_SWORD = 2;
    uint256 public constant CLASS_SHIELD = 3;
    uint256 public constant CLASS_AI_CHIP = 4;


    constructor(uint256[] memory _clazzes, uint256[] memory _amounts, string memory uri) ERC1155("") {
        _setURI(uri);
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
        require(_clazz <= 4, "Accessory does not exist.");
        _mint(msg.sender, _clazz, 1, _data);
    }

    function mintBatchAccessories(uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data) public whenNotPaused onlyOwner {
        uint256 _idsLength = _ids.length;
        for (uint256 i=0; i<_idsLength; i++) {
            require(_ids[i] > 0 && _ids[i] <= 4, "Accessory does not exist.");
        }
        _mintBatch(msg.sender, _ids, _amounts, _data);
    }

    function getWalletAccessories(address wallet, uint256[] calldata ids) public view whenNotPaused returns (uint256[] memory) {
        address[] memory wal = new address[](1);
        wal[0] = wallet;
        return balanceOfBatch(wal, ids);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal whenNotPaused override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

}

