// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IZhuiswapFactory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}
