// contracts/Robot.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./Whitelist.sol";

contract Robot is ERC721, ERC721Enumerable, Pausable, Whitelist {

    using SafeMath for uint256;

    uint256 private _saleTime = 1634451621; // 7PM EDT on November 1st
    uint256 private _price = 8 * 10**16; // .08 eth

    string private _baseTokenURI;

    // Address where funds are collected
    address payable private _wallet;

    // The robot accessory contract
    IERC1155 private _accessory;

    mapping(uint256 => RobotAttributes) public robots;

    enum State {
        Fighter, // 0
        Trainer, // 1
        Retired // 2
    }

    State constant defaultState = State.Fighter;

    struct RobotAttributes {
        uint256 robotIndex;
        string imageURI;
        uint256 wins;
        uint256 losses;
        State state;
    }

    constructor(string memory baseURI, address payable wallet) ERC721("Robot", "RBT") {
        setBaseURI(baseURI);
        _wallet = wallet;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
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

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

   // The following function override required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _createRobot(uint256 index) internal {
        robots[index] = RobotAttributes({
            robotIndex: index,
            imageURI: " ",
            wins: 0,
            losses: 0,
            state: defaultState
        });
    }

    // Count is how many they want to mint
    function mint(uint256 _count) public whenNotPaused payable {
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
            uint256 index = totalSupply + i;
            _createRobot(index);
            _safeMint(msg.sender, index);
        }
    }

    function updateRobotsRecords(uint256 winningRobotIndex, uint256 losingRobotIndex) public whenNotPaused onlyWhitelisted {
        robots[winningRobotIndex].wins += 1;
        robots[losingRobotIndex].losses += 1;
    }

    function setRobotAsFighter(uint256 robotIndex) public whenNotPaused onlyOwner {
        robots[robotIndex].state = State.Fighter;
    }

    function setRobotAsTrainer(uint256 robotIndex) public whenNotPaused onlyOwner {
        robots[robotIndex].state = State.Trainer;
    }

    function setRobotAsRetired(uint256 robotIndex) public whenNotPaused onlyOwner {
        robots[robotIndex].state = State.Retired;
    }

    function getRobotRecord(uint256 robotIndex) public view returns(uint256, uint256) {
        return(robots[robotIndex].wins, robots[robotIndex].losses);
    }

    function getRobotState(uint256 robotIndex) public view returns(State) {
        return robots[robotIndex].state;
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

    function withdrawAll() public payable onlyOwner {
        require(_wallet.send(address(this).balance));
    }
}
