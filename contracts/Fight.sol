// contracts/Fight.sol
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Fight is ReentrancyGuard, Pausable, Ownable {

    using SafeMath for uint256;

    uint256 public ANTE_PRICE = 10 * 10**18;

    address _Celo = 0xF194afDf50B03e69Bd7D057c1Aa9e10c9954E4C9;
    address _cUSD = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    // Address where funds are collected
    address payable private _wallet;

    uint256 private _rake;
    uint256 private RAKE_AMOUNT = 1 * 10**18;

    struct FightInfo {
        address fighter1;
        address fighter2;
        address winner;
        uint256 deposit;
        bool isPaidOut;
    }

    mapping(uint256 => FightInfo) public fights;

    event Withdrawal(address indexed to, uint256 amount);
    event Winner(address indexed winner);
    event Ante(address indexed from, uint256 amount);

    constructor(address payable wallet) {
        require(wallet != address(0), "wallet is the zero address");
        _wallet = wallet;
    }

    function createFight(uint256 fightId, address fighter1, address fighter2) public whenNotPaused onlyOwner {
        fights[fightId].fighter1 = fighter1;
        fights[fightId].fighter2 = fighter2;
    }

    function updateFight(uint256 fightId, address winner) public whenNotPaused onlyOwner {
        address fighter1 = fights[fightId].fighter1;
        address fighter2 = fights[fightId].fighter2;
        require(fighter1 == winner || fighter2 == winner, "The winner is not one of the fighters");
        fights[fightId].winner = winner;
        emit Winner(winner);
    }

    function ante(uint256 fightId) public whenNotPaused payable {
        address fighter1 = fights[fightId].fighter1;
        address fighter2 = fights[fightId].fighter2;
        require(!fights[fightId].isPaidOut, "Fight already paid out");
        require(fighter1 == msg.sender || fighter2 == msg.sender, "You are not one of the fighters");
        require(ANTE_PRICE == msg.value, "You need to ante the correct amount");
        fights[fightId].deposit.add(msg.value).sub(RAKE_AMOUNT);
        _rake.add(RAKE_AMOUNT);
        emit Ante(msg.sender, msg.value);
    }

    function withdraw(uint256 fightId, address token) public {
        require(!fights[fightId].isPaidOut, "Fight already paid out");
        require(token == _Celo || token == _cUSD, "token is not celo or cUSD");
        require(fights[fightId].deposit > 0, "There is no balance for this fight");
        require(fights[fightId].winner == msg.sender , "You are not with winner of the fight");
        fights[fightId].isPaidOut = true;
        require(IERC20(token).transfer(msg.sender, fights[fightId].deposit), "Withdrawing cUSD failed.");
        emit Withdrawal(msg.sender, fights[fightId].deposit);
    }

    function withdrawRake(address token) public onlyOwner {
        require(token == _Celo || token == _cUSD, "token is not celo or cUSD");
        _rake = 0;
        require(IERC20(token).transfer(_wallet, _rake), "Withdrawing cUSD failed.");
    }
}
