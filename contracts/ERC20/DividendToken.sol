// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DividendToken is ERC20, Ownable {
    uint256 private _totalDividends;

    // 用户上次领取分红时的累计分红总数映射
    mapping(address => uint256) private _lastTotalDividends;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    function distributeDividends(uint256 amount) public onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        _totalDividends += amount;
        _mint(address(this), amount);
    }

    function claimDividends() public {
        uint256 owed = unclaimedDividends(msg.sender);
        _lastTotalDividends[msg.sender] = _totalDividends;
        if (owed > 0) {
            _transfer(address(this), msg.sender, owed);
        }
    }

    function unclaimedDividends(address account) public view returns (uint256) {
        uint256 newDividends = _totalDividends - _lastTotalDividends[account];
        uint256 accountBalance = balanceOf(account);
        return (accountBalance * newDividends) / totalSupply();
    }
}
