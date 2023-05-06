pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LockableToken is ERC20, Ownable {
    // 地址锁定状态映射
    mapping(address => bool) private _locked;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    function lock(address account) public onlyOwner {
        _locked[account] = true;
        emit Locked(account);
    }

    function unlock(address account) public onlyOwner {
        _locked[account] = false;
        emit Unlocked(account);
    }

    function isLocked(address account) public view returns (bool) {
        return _locked[account];
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!_locked[from], "Token transfer from locked address");
        require(!_locked[to], "Token transfer to locked address");
    }

    event Locked(address account);
    event Unlocked(address account);
}
