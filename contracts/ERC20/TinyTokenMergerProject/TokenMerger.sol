// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract TokenMerger {
    using SafeMath for uint256;

    IERC20 public mergedToken;
    mapping(address => uint256) public tokenRatios;

    constructor(IERC20 _mergedToken) {
        mergedToken = _mergedToken;
    }
    function setTokenRatio(address token, uint256 ratio) public {
        require(ratio > 0, "Ratio must be greater than 0");
        tokenRatios[token] = ratio;
    }
    function mergeTokens(address[] memory tokens, uint256[] memory amounts) public {
        require(tokens.length == amounts.length, "Tokens and amounts arrays must have the same length");

        uint256 totalMergedAmount = 0;

        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 amount = amounts[i];
            uint256 ratio = tokenRatios[token];

            require(ratio > 0, "Token ratio not set");

            uint256 mergedAmount = amount.mul(ratio);
            totalMergedAmount = totalMergedAmount.add(mergedAmount);

            IERC20(token).transferFrom(msg.sender, address(this), amount);
        }

        mergedToken.transfer(msg.sender, totalMergedAmount);
    }
}
