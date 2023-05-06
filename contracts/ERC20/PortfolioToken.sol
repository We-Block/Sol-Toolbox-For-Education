// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PortfolioToken {
    using SafeMath for uint256;

    struct Portfolio {
        address[] tokens;
        mapping(address => uint256) balances;
    }

    mapping(address => Portfolio) private portfolios;

    function addToPortfolio(address token, uint256 amount) public {
        Portfolio storage userPortfolio = portfolios[msg.sender];
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        if (userPortfolio.balances[token] == 0) {
            userPortfolio.tokens.push(token);
        }

        userPortfolio.balances[token] = userPortfolio.balances[token].add(amount);
    }

    function removeFromPortfolio(address token, uint256 amount) public {
        Portfolio storage userPortfolio = portfolios[msg.sender];
        require(userPortfolio.balances[token] >= amount, "Insufficient balance");

        IERC20(token).transfer(msg.sender, amount);
        userPortfolio.balances[token] = userPortfolio.balances[token].sub(amount);

        if (userPortfolio.balances[token] == 0) {
            // Remove the token from the user's portfolio if the balance is 0
            for (uint256 i = 0; i < userPortfolio.tokens.length; i++) {
                if (userPortfolio.tokens[i] == token) {
                    userPortfolio.tokens[i] = userPortfolio.tokens[userPortfolio.tokens.length - 1];
                    userPortfolio.tokens.pop();
                    break;
                }
            }
        }
    }

    function getPortfolioTokens(address user) public view returns (address[] memory) {
        return portfolios[user].tokens;
    }

    function getPortfolioTokenBalance(address user, address token) public view returns (uint256) {
        return portfolios[user].balances[token];
    }
}
