// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LendingPool {
    using SafeMath for uint256;

    IERC20 public lendingToken;
    uint256 public totalBorrows;
    uint256 public totalDeposits;
    mapping(address => uint256) public userBorrows;
    mapping(address => uint256) public userDeposits;

    uint256 public borrowRate;
    uint256 public depositRate;

    constructor(IERC20 _lendingToken, uint256 _borrowRate, uint256 _depositRate) {
        lendingToken = _lendingToken;
        borrowRate = _borrowRate;
        depositRate = _depositRate;
    }

    function deposit(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        lendingToken.transferFrom(msg.sender, address(this), amount);
        totalDeposits = totalDeposits.add(amount);
        userDeposits[msg.sender] = userDeposits[msg.sender].add(amount);
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(userDeposits[msg.sender] >= amount, "Insufficient balance");
        lendingToken.transfer(msg.sender, amount);
        totalDeposits = totalDeposits.sub(amount);
        userDeposits[msg.sender] = userDeposits[msg.sender].sub(amount);
    }
    
    function borrow(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(totalDeposits >= totalBorrows.add(amount), "Insufficient liquidity");

        uint256 interest = amount.mul(borrowRate).div(1e18);
        lendingToken.transfer(msg.sender, amount);

        totalBorrows = totalBorrows.add(amount).add(interest);
        userBorrows[msg.sender] = userBorrows[msg.sender].add(amount).add(interest);
    }

    function repay(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(userBorrows[msg.sender] >= amount, "Insufficient borrowed balance");

        lendingToken.transferFrom(msg.sender, address(this), amount);

        totalBorrows = totalBorrows.sub(amount);
        userBorrows[msg.sender] = userBorrows[msg.sender].sub(amount);
    }
    function getUserDeposit(address user) public view returns (uint256) {
        return userDeposits[user];
    }

    function getUserBorrow(address user) public view returns (uint256) {
        return userBorrows[user];
    }

    function getPoolState() public view returns (uint256, uint256) {
        return (totalDeposits, totalBorrows);
    }
}
