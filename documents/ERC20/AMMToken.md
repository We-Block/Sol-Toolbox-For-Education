# AMMToken & AMMPair Smart Contracts

这是一个使用Solidity编写的简单自动化做市商（AMM）智能合约。它包括两个主要的合约：`AMMToken` 和 `AMMPair`。

## AMMToken

`AMMToken` 是一个继承自 OpenZeppelin 库中的 `ERC20` 合约的代币合约。它实现了一个简单的 ERC20 代币，具有创建代币和分配初始供应量的功能。

### 构造函数

构造函数接受三个参数：名称（`name`），符号（`symbol`）和初始供应量（`initialSupply`）。然后，它会调用 `_mint` 函数，将初始供应量发送给部署合约的用户。

## AMMPair

`AMMPair` 是一个用于两种代币的交换和流动性提供的智能合约。它使用了 OpenZeppelin 库中的 `SafeMath` 和 `SafeERC20` 工具库。该合约有以下功能：

### 构造函数

构造函数接受两个参数：`_token0` 和 `_token1`，它们分别是交换对中的两种代币。这些代币会被分配给合约的 `token0` 和 `token1` 变量。

### addLiquidity

`addLiquidity` 函数接受两个参数：`amount0` 和 `amount1`。这些参数代表用户要添加到流动性池中的 `token0` 和 `token1` 的数量。该函数从用户的地址转移代币到合约地址，并将它们添加到相应的储备中。

### removeLiquidity

`removeLiquidity` 函数接受两个参数：`amount0` 和 `amount1`。这些参数表示用户希望从流动性池中提取的 `token0` 和 `token1` 的数量。在提取之前，函数会检查储备是否足够。然后，从合约地址将代币发送回用户，并从储备中减去相应的数量。

### getReserves

`getReserves` 函数返回两个储备值：`reserve0` 和 `reserve1`，它们分别表示 `token0` 和 `token1` 的储备。

### swap

`swap` 函数允许用户通过输入一定数量的一种代币（`amountIn`），以换取另一种代币（`amountOut`）。该函数接受五个参数：`amountIn`、`tokenIn`、`amountOut`、`tokenOut` 和 `to`。它首先检查输入和输出代币是否有效，然后计算输出金额。接下来，它从发送者转移输入代币，并将输出代币发送给接收者。最后，它更新储备。

## 总结

这个简单的 AMM 智能合约示例展示了如何创建 ERC20 代币并在两种代币之间实现交换和流动性提供。这是一个基本的实现，实际应用中的自动化做市商（如 Uniswap 和 Sushiswap）通常会包括更多功能和优化。