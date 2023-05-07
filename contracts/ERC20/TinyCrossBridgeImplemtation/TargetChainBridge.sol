// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract TargetChainBridge is Ownable {
    ERC20 public token;

    event Unlocked(address indexed recipient, uint256 amount);
    event Mint(address indexed account, uint256 amount);

    constructor(ERC20 _token) {
        token = _token;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        token._mint(account, amount);
        emit Mint(account, amount);
    }

    function unlockTokens(address recipient, uint256 amount) public onlyOwner {
        _mint(recipient, amount);
        emit Unlocked(recipient, amount);
    }

    function lockTokens(address sender, uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        token._burn(sender, amount);
    }
}
