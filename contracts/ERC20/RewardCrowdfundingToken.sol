// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RewardCrowdfundingToken is ERC20 {
    using SafeMath for uint256;

    address public projectOwner;
    uint256 public fundingGoal;
    uint256 public deadline;
    uint256 public totalFundsRaised;
    bool public fundingGoalReached;
    bool public isCrowdfundingClosed;
    mapping(address => uint256) public fundsByBacker;

    event GoalReached(address recipient, uint256 totalFundsRaised);
    event FundTransfer(address backer, uint256 amount, bool isContribution);

    IERC20 public rewardToken;
    mapping(address => bool) public rewardsDistributed;
    address[] private backers;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _fundingGoal,
        uint256 _durationInMinutes,
        address _projectOwner,
        IERC20 _rewardToken
    ) ERC20(name, symbol) {
        projectOwner = _projectOwner;
        fundingGoal = _fundingGoal;
        deadline = block.timestamp + (_durationInMinutes * 1 minutes);
        rewardToken = _rewardToken;
    }

    function contribute() external payable {
        require(!isCrowdfundingClosed, "Crowdfunding is closed");
        uint256 amount = msg.value;
        fundsByBacker[msg.sender] = fundsByBacker[msg.sender].add(amount);
        totalFundsRaised = totalFundsRaised.add(amount);
        _mint(msg.sender, amount);
        emit FundTransfer(msg.sender, amount, true);
    }

    function checkGoalReached() public {
        require(block.timestamp >= deadline, "Deadline not reached yet");
        if (totalFundsRaised >= fundingGoal) {
            fundingGoalReached = true;
            emit GoalReached(projectOwner, totalFundsRaised);
        }
        isCrowdfundingClosed = true;
    }

    function distributeRewards() external {
        require(isCrowdfundingClosed, "Crowdfunding is not closed yet");
        require(fundingGoalReached, "Funding goal not reached");
        require(msg.sender == projectOwner, "Only project owner can distribute rewards");
        require(!rewardsDistributed[msg.sender], "Rewards already distributed");

        for (uint256 i = 0; i < getBackerCount(); i++) {
            address backer = getBacker(i);
            uint256 contributedAmount = fundsByBacker[backer];
            uint256 rewardAmount = calculateReward(contributedAmount);

            rewardToken.safeTransfer(backer, rewardAmount);
        }

        rewardsDistributed[msg.sender] = true;
    }

    function calculateReward(uint256 contributionAmount) internal pure returns (uint256) {
        // Implement your own reward calculation logic here
        // For example, you can give 1 reward token for every 1 ether contributed
        return contributionAmount;
    }

    function withdrawFunds() external {
        require(isCrowdfundingClosed, "Crowdfunding is not closed yet");
        require(fundingGoalReached, "Funding goal not reached");
        require(msg.sender == projectOwner, "Only project owner can withdraw funds");

        uint256 amountToTransfer = address(this).balance;
        (bool success, ) = projectOwner.call{value: amountToTransfer}("");
        require(success, "Failed to send funds to the project owner");
        emit FundTransfer(projectOwner, amountToTransfer, false);
    }

    function refund() external {
        require(isCrowdfundingClosed, "Crowdfunding is not closed yet");
        require(!fundingGoalReached, "Funding goal reached, cannot refund");

        uint256 amountToRefund = fundsByBacker[msg.sender];
        require(amountToRefund > 0, "Nothing to refund");

        fundsByBacker[msg.sender] = 0;
        _burn(msg.sender, amountToRefund);

        (bool success, ) = msg.sender.call{value: amountToRefund}("");
        require(success, "Failed to send funds to backer");
        emit FundTransfer(msg.sender, amountToRefund, false);
    }
    function getBackerCount() public view returns (uint256) {
        return backers.length;
    }

    function getBacker(uint256 index) public view returns (address) {
        require(index < backers.length, "Index out of bounds");
        return backers[index];
    }

    function addBacker(address backer) internal {
        if (fundsByBacker[backer] == 0) {
            backers.push(backer);
        }
    }

    // 防止有人意外发送了ETH到合约
    fallback() external payable {
        revert("Do not send ETH directly");
    }
}
