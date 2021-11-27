// contracts/Robot.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./Whitelist.sol";

contract Robot is ERC721, ERC721URIStorage, ERC721Enumerable, Pausable, Whitelist {
    using SafeMath for uint256;

    uint256 public ROBOT_PRICE = 5 * 10**18;

    string private _baseTokenURI;

    // Address where funds are collected
    address payable private _wallet;

    string[] private robotType = ["Tank", "Speedy", "Defender", "Attacker"];
    uint256[] private strength = [20, 10, 10, 20];
    uint256[] private agility = [10, 20, 10, 20];
    uint256[] private ai = [10, 20, 20, 10];
    uint256[] private defense = [20, 10, 20, 10];

    mapping(uint256 => RobotAttributes) public robots;

    string[] private robotURIs = ["0.json", "1.json", "2.json", "3.json"];

    enum State {
        Fighter, // 0
        Trainer, // 1
        Retired // 2
    }

    State constant defaultState = State.Fighter;

    struct RobotAttributes {
        uint256 robotIndex;
        uint256 wins;
        uint256 losses;
        State state;
        string robotName;
        string robotType;
        uint256 health;
        uint256 strength;
        uint256 agility;
        uint256 ai;
        uint256 defense;
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

    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
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

   // The following function override required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _createRobot(uint256 index, uint256 botType, string memory robotName) internal {
        robots[index] = RobotAttributes({
            robotIndex: index,
            wins: 0,
            losses: 0,
            state: defaultState,
            robotName: robotName,
            robotType: robotType[botType],
            health: 300,
            strength: strength[botType],
            agility: agility[botType],
            ai: ai[botType],
            defense: defense[botType]
        });
    }

    // Count is how many they want to mint
    function mint(uint256 botType, string memory robotName) public whenNotPaused payable {
        require(botType < 4, "There is no robot of that type");
        require(
            msg.value >= ROBOT_PRICE || owner() == _msgSender(),
            "The value submitted with this transaction is too low."
        );

        uint256 totalSupply = totalSupply();
        uint256 tokenId = totalSupply + 1;
        _createRobot(tokenId, botType, robotName);
        _safeMint(msg.sender, tokenId);
        string memory robotURI = robotURIs[botType];
        _setTokenURI(tokenId, robotURI);
    }

    function updateRobotWinRecord(uint256 robotIndex) public whenNotPaused onlyWhitelisted {
        robots[robotIndex].wins += 1;
    }

    function updateRobotLossRecord(uint256 robotIndex) public whenNotPaused onlyWhitelisted {
        robots[robotIndex].losses += 1;
    }

    function updateRobotName(uint256 robotIndex, string memory value) public whenNotPaused onlyWhitelisted {
        robots[robotIndex].robotName = value;
    }

    function updateRobotHealth(uint256 robotIndex, uint256 value) public whenNotPaused onlyWhitelisted {
        robots[robotIndex].health += value;
    }

    function updateRobotStrength(uint256 robotIndex, uint256 value) public whenNotPaused onlyWhitelisted {
        robots[robotIndex].strength += value;
    }

    function updateRobotAgility(uint256 robotIndex, uint256 value) public whenNotPaused onlyWhitelisted {
        robots[robotIndex].agility += value;
    }

    function updateRobotAi(uint256 robotIndex, uint256 value) public whenNotPaused onlyWhitelisted {
        robots[robotIndex].ai += value;
    }

    function updateRobotDefense(uint256 robotIndex, uint256 value) public whenNotPaused onlyWhitelisted {
        robots[robotIndex].defense += value;
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
