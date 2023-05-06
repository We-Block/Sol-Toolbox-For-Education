// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract AMMToken is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}
contract AMMPair {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token0;
    IERC20 public token1;

    uint256 public reserve0;
    uint256 public reserve1;

    constructor(IERC20 _token0, IERC20 _token1) {
        token0 = _token0;
        token1 = _token1;
    }
    
    function addLiquidity(uint256 amount0, uint256 amount1) public {
        token0.safeTransferFrom(msg.sender, address(this), amount0);
        token1.safeTransferFrom(msg.sender, address(this), amount1);
        reserve0 = reserve0.add(amount0);
        reserve1 = reserve1.add(amount1);
    }

    function removeLiquidity(uint256 amount0, uint256 amount1) public {
        require(reserve0 >= amount0, "Insufficient reserve0");
        require(reserve1 >= amount1, "Insufficient reserve1");

        token0.safeTransfer(msg.sender, amount0);
        token1.safeTransfer(msg.sender, amount1);

        reserve0 = reserve0.sub(amount0);
        reserve1 = reserve1.sub(amount1);
    }
    function getReserves() public view returns (uint256, uint256) {
        return (reserve0, reserve1);
    }
    
    function swap(uint256 amountIn, address tokenIn, uint256 amountOut, address tokenOut, address to) public {
    require(amountIn > 0, "AmountIn must be greater than 0");
    require(amountOut > 0, "AmountOut must be greater than 0");
    require(tokenIn == address(token0) || tokenIn == address(token1), "Invalid input token");
    require(tokenOut == address(token0) || tokenOut == address(token1), "Invalid output token");
    require(tokenIn != tokenOut, "Input and output tokens must be different");

    IERC20 inputToken = IERC20(tokenIn);
    IERC20 outputToken = IERC20(tokenOut);

    uint256 inputReserve;
    uint256 outputReserve;

    if (tokenIn == address(token0)) {
        inputReserve = reserve0;
        outputReserve = reserve1;
    } else {
        inputReserve = reserve1;
        outputReserve = reserve0;
    }

    require(inputReserve >= amountIn, "Insufficient input reserve");
    require(outputReserve >= amountOut, "Insufficient output reserve");

    uint256 calculatedAmountOut = amountIn.mul(outputReserve).div(inputReserve);
    require(calculatedAmountOut >= amountOut, "Invalid amountOut");

    inputToken.transferFrom(msg.sender, address(this), amountIn);
    outputToken.transfer(to, amountOut);

    if (tokenIn == address(token0)) {
        reserve0 = reserve0.add(amountIn);
        reserve1 = reserve1.sub(amountOut);
    } else {
        reserve0 = reserve0.sub(amountOut);
        reserve1 = reserve1.add(amountIn);
    }
}
}