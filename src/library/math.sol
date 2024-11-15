// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../Zhuiswap-Pair.sol";
import "../Zhuiswap-Factory.sol";

library math {
    //定义一个平方根函数
    function sqrt(uint256 y) public pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // 如果 y == 0，则 z 默认为 0
    }

    //确保池子token比例一致
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    //根据恒定公式计算输出值
    function getAmountOut(
        uint256 poolReserveA,
        uint256 poolReserveB,
        uint256 amountIn,
        uint256 minOutput
    ) public pure returns (uint256 output) {
        // x * y = k
        uint256 k = poolReserveA * poolReserveB;

        uint256 x = (poolReserveA + amountIn);

        uint256 y = k / x;

        output = y - poolReserveB;

        require(output >= minOutput, "output fail");

        return output;
    }
}
