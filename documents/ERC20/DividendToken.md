# DividendToken智能合约

## 简介

这是一个基于 Solidity 的智能合约，名称为 DividendToken。它是一个 ERC20 标准的代币合约，可用于分发分红。

## 安装

本合约依赖于 OpenZeppelin 库，因此需要先安装该库。可以在终端使用以下命令进行安装：

`npm install @openzeppelin/contracts`

## 合约结构

DividendToken 合约继承了 ERC20 和 Ownable 合约。它有一个私有变量 `_totalDividends`，记录当前累计分红总数。另外，使用了一个映射 `_lastTotalDividends`，记录每个账户上次领取分红时的累计分红总数。

合约有以下主要函数：

- `distributeDividends`: 只有合约所有者可以调用，用于分发分红。
- `claimDividends`: 用于领取分红。
- `unclaimedDividends`: 用于查询账户未领取的分红。

## 注意事项

- 只有合约所有者可以分发分红。
- 用户需要手动调用 `claimDividends` 来领取分红。
- `_lastTotalDividends` 映射记录的是上次领取分红时的累计分红总数，因此初始值为 0。