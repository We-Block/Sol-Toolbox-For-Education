// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AntiManipulationToken is ERC20 {
    uint256 public maxTransactionAmount;
    uint256 public priceChangeThreshold;
    uint256 public lastPrice;
    uint256 public lastPriceUpdateTimestamp;
    uint256 public priceUpdateInterval;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxTransactionAmount,
        uint256 _priceChangeThreshold,
        uint256 _priceUpdateInterval
    ) ERC20(name, symbol) {
        maxTransactionAmount = _maxTransactionAmount;
        priceChangeThreshold = _priceChangeThreshold;
        priceUpdateInterval = _priceUpdateInterval;
        lastPrice = 0;
        lastPriceUpdateTimestamp = block.timestamp;
    }

    function updatePrice(uint256 newPrice) external {
        require(
            block.timestamp >= lastPriceUpdateTimestamp + priceUpdateInterval,
            "Price update interval not reached"
        );

        uint256 priceDifference = newPrice > lastPrice ? newPrice - lastPrice : lastPrice - newPrice; //假设我们可以通过预言机或者liquidpool喂价
        require(
            priceDifference <= priceChangeThreshold,
            "Price change exceeds the allowed threshold"
        );

        lastPrice = newPrice;
        lastPriceUpdateTimestamp = block.timestamp;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(amount <= maxTransactionAmount, "Transaction amount exceeds the limit");

        super._transfer(sender, recipient, amount);
    }
}
