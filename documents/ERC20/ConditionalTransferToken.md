# ConditionalTransferToken 智能合约

## 概述

这是一个基于以太坊的智能合约，实现了一种条件转账的 ERC20 代币。通过添加定时转账功能，可以在特定的时间触发转账操作，从而实现更加灵活的转账方式。

## 合约结构

### ConditionalTransferToken

`ConditionalTransferToken` 合约继承自 `ERC20`，并扩展了两个新的方法，用于添加定时转账和处理定时转账：

- `scheduleTimedTransfer(address to, uint256 amount, uint256 triggerTime)`：添加一个定时转账，并将转账金额从发送者的账户转移到合约账户。`to` 参数指定接收者地址，`amount` 参数指定转账金额，`triggerTime` 参数指定转账触发时间。
- `processTimedTransfers()`：处理所有已经触发的定时转账。该方法会遍历所有定时转账，如果当前时间大于或等于转账触发时间，则将转账金额从合约账户转移到接收者地址。

`ConditionalTransferToken` 合约还包含一个结构体 `TimedTransfer`，用于存储定时转账的详细信息：

solidityCopy code

`struct TimedTransfer { address from; address to; uint256 amount; uint256 triggerTime; }`

### SafeMath

`SafeMath` 是一个用于执行数学运算的库，可以避免整型溢出等问题。`ConditionalTransferToken` 合约中使用了 `SafeMath` 的 `add` 和 `sub` 方法。

## 许可证

该合约使用 MIT 许可证，详情请参阅代码中的 SPDX 许可证标识符。