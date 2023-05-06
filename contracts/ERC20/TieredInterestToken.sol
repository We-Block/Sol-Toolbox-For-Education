// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TieredInterestToken is ERC20 {
    using SafeMath for uint256;

    uint256 constant public ONE_YEAR = 365 days;

    struct Stake {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Stake[]) public stakes;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function stake(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, address(this), amount);
        stakes[msg.sender].push(Stake(amount, block.timestamp));
    }

    function unstake(uint256 index) public {
        require(index < stakes[msg.sender].length, "Invalid index");

        Stake memory stakeInfo = stakes[msg.sender][index];
        uint256 reward = calculateReward(stakeInfo.amount, stakeInfo.timestamp);
        uint256 totalAmount = stakeInfo.amount.add(reward);

        // Remove the stake from the stakes array
        stakes[msg.sender][index] = stakes[msg.sender][stakes[msg.sender].length - 1];
        stakes[msg.sender].pop();

        _transfer(address(this), msg.sender, totalAmount);
    }

    function calculateReward(uint256 amount, uint256 stakeTimestamp) public view returns (uint256) {
        uint256 holdingTime = block.timestamp.sub(stakeTimestamp);

        uint256 interestRate;
        if (holdingTime < ONE_YEAR) {
            interestRate = 5; // 5% annual interest for holding less than 1 year
        } else if (holdingTime < 2 * ONE_YEAR) {
            interestRate = 10; // 10% annual interest for holding between 1 and 2 years
        } else {
            interestRate = 15; // 15% annual interest for holding more than 2 years
        }

        uint256 reward = amount.mul(interestRate).mul(holdingTime).div(100).div(ONE_YEAR);
        return reward;
    }
}
