// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSwap is Ownable {
    IERC20 public token1;
    IERC20 public token2;
    uint256 public swapRate; // 交换比例，以 token1 / token2 表示

    constructor(
        address _token1,
        address _token2,
        uint256 _swapRate
    ) {
        require(_token1 != address(0) && _token2 != address(0), "Invalid token addresses");
        require(_swapRate > 0, "Invalid swap rate");

        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
        swapRate = _swapRate;
    }
    function swapTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        uint256 token2Amount = amount * swapRate;

        // 将用户的 Token1 转移到合约地址
        require(token1.transferFrom(msg.sender, address(this), amount), "Token1 transfer failed");

        // 向用户发送 Token2
        require(token2.transfer(msg.sender, token2Amount), "Token2 transfer failed");

        // 触发交换事件
        emit TokensSwapped(msg.sender, amount, token2Amount);
    }
    function withdrawTokens(IERC20 token, uint256 amount) external onlyOwner {
        require(token.transfer(msg.sender, amount), "Token withdrawal failed");
    }

    event TokensSwapped(address user, uint256 token1Amount, uint256 token2Amount);
}