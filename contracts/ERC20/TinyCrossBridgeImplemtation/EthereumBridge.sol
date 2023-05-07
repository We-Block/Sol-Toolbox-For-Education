// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract EthereumBridge is Ownable {
    IERC20 public token;
    uint256 public nonce;

    event Locked(address indexed sender, uint256 amount, uint256 targetChainNonce);

    constructor(IERC20 _token) {
        token = _token;
    }

    function lockTokens(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        token.transferFrom(msg.sender, address(this), amount);
        nonce++;
        emit Locked(msg.sender, amount, nonce);
    }

    function unlockTokens(address recipient, uint256 amount) public onlyOwner {
        token.transfer(recipient, amount);
    }
}
