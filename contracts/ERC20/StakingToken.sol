// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract StakingToken is ERC20 {
    using SafeMath for uint256;

    IERC20 public rewardsToken;
    uint256 public rewardsRate;
    uint256 public constant REWARDS_DURATION = 30 days;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
    }

    mapping(address => Stake) public stakes;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        IERC20 _rewardsToken,
        uint256 _rewardsRate
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        rewardsToken = _rewardsToken;
        rewardsRate = _rewardsRate;
    }
    function stake(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");

        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount == 0, "Stake already exists");

        transferFrom(msg.sender, address(this), amount);

        userStake.amount = amount;
        userStake.startTime = block.timestamp;
        userStake.endTime = block.timestamp.add(REWARDS_DURATION);
    }
    function claimRewards() public {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No stake found");
        require(block.timestamp >= userStake.endTime, "Staking period not over");

        uint256 rewards = userStake.amount.mul(rewardsRate).div(100);
        rewardsToken.transfer(msg.sender, rewards);

        _burn(address(this), userStake.amount);

        delete stakes[msg.sender];
    }
}
