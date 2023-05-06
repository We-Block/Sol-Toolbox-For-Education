// SPDX-License-Identifier: MIT
contract EthereumBridge is Ownable {
    CrossChainToken public token;
    uint256 public nonce;

    event Locked(address indexed sender, uint256 amount, uint256 targetChainNonce);

    constructor(CrossChainToken _token) {
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
