// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract TokenMixer {
    using ECDSA for bytes32;

    IERC20 public token;
    uint256 private nonce;
    mapping(bytes32 => bool) private usedWithdrawHashes;

    event Deposit(address indexed sender, uint256 amount);
    event Withdraw(address indexed recipient, uint256 amount);

    constructor(IERC20 _token) {
        token = _token;
    }

    function deposit(uint256 amount) external {
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        emit Deposit(msg.sender, amount);
    }

    function withdraw(
        address recipient,
        uint256 amount,
        bytes calldata signature
    ) external {
        bytes32 withdrawHash = _generateWithdrawHash(recipient, amount);
        address signer = withdrawHash.recover(signature);

        require(signer != address(0), "Invalid signature");
        require(!usedWithdrawHashes[withdrawHash], "Withdraw hash already used");
        usedWithdrawHashes[withdrawHash] = true;

        require(token.transfer(recipient, amount), "Transfer failed");
        emit Withdraw(recipient, amount);
    }

    function _generateWithdrawHash(address recipient, uint256 amount) private view returns (bytes32) {
        return keccak256(abi.encodePacked(recipient, amount, nonce));
    }

    function generateWithdrawHash(address recipient, uint256 amount) external view returns (bytes32) {
        return _generateWithdrawHash(recipient, amount);
    }

    function incrementNonce() external {
        nonce++;
    }
}
