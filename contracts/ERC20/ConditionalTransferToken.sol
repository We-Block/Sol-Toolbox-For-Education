// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ConditionalTransferToken is ERC20 {
    using SafeMath for uint256;

    struct TimedTransfer {
        address from;
        address to;
        uint256 amount;
        uint256 triggerTime;
    }

    TimedTransfer[] public timedTransfers;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function scheduleTimedTransfer(address to, uint256 amount, uint256 triggerTime) public {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, address(this), amount);
        timedTransfers.push(TimedTransfer(msg.sender, to, amount, triggerTime));
    }

    function processTimedTransfers() public {
        uint256 i = 0;
        while (i < timedTransfers.length) {
            TimedTransfer memory tt = timedTransfers[i];
            if (block.timestamp >= tt.triggerTime) {
                _transfer(address(this), tt.to, tt.amount);
                _removeTimedTransfer(i);
            } else {
                i++;
            }
        }
    }

    function _removeTimedTransfer(uint256 index) private {
        require(index < timedTransfers.length, "Invalid index");
        timedTransfers[index] = timedTransfers[timedTransfers.length - 1];
        timedTransfers.pop();
    }
}
