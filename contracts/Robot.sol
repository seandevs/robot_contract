// contracts/Robot.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Robot is ERC721Enumerable, Ownable {

    uint256 private _saleTime = 1634451621; // 7PM EDT on November 1st
    uint256 private _price = 8 * 10**16; // .08 eth

    string private _baseTokenURI;

    constructor(string memory baseURI) ERC721("Robot", "RBT") {
        setBaseURI(baseURI);
    }

    function setSaleTime(uint256 time) public onlyOwner {
        _saleTime = time;
    }

    function getSaleTime() public view returns (uint256) {
        return _saleTime;
    }

    function isSaleOpen() public view returns (bool) {
        return block.timestamp >= _saleTime;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    // Count is how many they want to mint
    function mint(uint256 _count) public payable {
        uint256 totalSupply = totalSupply();
        require(_count < 21, "Exceeds the max token per transaction limit.");
        require(
            msg.value >= _price * _count,
            "The value submitted with this transaction is too low."
        );
        require(
            block.timestamp >= _saleTime,
            "The robot sale is not currently open."
        );

        for (uint256 i; i < _count; i++) {
            _safeMint(msg.sender, totalSupply + i);
        }
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        }

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function withdrawAll() public payable {
        require(payable(0x2B25A827C40CA0c22F2906b3c262B834E147C4fE).send(address(this).balance));
    }
}
