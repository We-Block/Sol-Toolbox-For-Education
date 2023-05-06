// SPDX-License-Identifier: MIT
contract TargetChainBridge is Ownable {
    CrossChainToken public token;

    event Unlocked(address indexed recipient, uint256 amount);

    constructor(CrossChainToken _token) {
        token = _token;
    }

    function unlockTokens(address recipient, uint256 amount) public onlyOwner {
        token.mint(recipient, amount);
        emit Unlocked(recipient, amount);
    }

    function lockTokens(address sender, uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        token.burn(sender, amount);
    }
}
