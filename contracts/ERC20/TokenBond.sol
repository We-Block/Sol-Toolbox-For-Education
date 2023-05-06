// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenBond is Ownable {
    IERC20 public token;
    uint256 public interestRate; // in basis points, e.g., 500 = 5%
    uint256 public bondDuration; // in seconds

    struct Bond {
        uint256 amount;
        uint256 purchaseTimestamp;
    }

    mapping(address => Bond) public bonds;

    constructor(
        IERC20 _token,
        uint256 _interestRate,
        uint256 _bondDuration
    ) {
        token = _token;
        interestRate = _interestRate;
        bondDuration = _bondDuration;
    }

    function purchaseBond(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(bonds[msg.sender].amount == 0, "Bond already purchased");

        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        bonds[msg.sender] = Bond({
            amount: amount,
            purchaseTimestamp: block.timestamp
        });
    }

    function redeemBond() external {
        Bond storage userBond = bonds[msg.sender];
        require(userBond.amount > 0, "No bond purchased");
        require(block.timestamp >= userBond.purchaseTimestamp + bondDuration, "Bond not matured yet");

        uint256 interest = (userBond.amount * interestRate) / 10000;
        uint256 totalAmount = userBond.amount + interest;

        require(token.transfer(msg.sender, totalAmount), "Token transfer failed");

        delete bonds[msg.sender];
    }

    function updateInterestRate(uint256 newInterestRate) external onlyOwner {
        interestRate = newInterestRate;
    }

    function updateBondDuration(uint256 newBondDuration) external onlyOwner {
        bondDuration = newBondDuration;
    }
}
