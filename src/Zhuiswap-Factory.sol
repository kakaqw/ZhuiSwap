// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Zhuiswap-Pair.sol";
// 错误定义
error IdenticalAddresses();
error ZeroAddress();
error PairAlreadyExists();

contract ZhuiswapFactory {
    mapping(address => mapping(address => address)) public pairs;
    address[] public allPairs;

    event CreatePair(address pair, address token0, address token1);

    function createPair(
        address tokenA,
        address tokenB
    ) public returns (address) {
        if (tokenA == tokenB) revert IdenticalAddresses();
        if (tokenA == address(0) || tokenB == address(0)) revert ZeroAddress();
        address pairAddress;

        //确定交易对的token顺序
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);

        //检查交易对是否存在
        if (pairs[token0][token1] != address(0)) revert PairAlreadyExists();

        //创建交易对
        pairAddress = address(new ZhuiswapPair(token0, token1));
        allPairs.push(pairAddress);

        //更新交易对
        pairs[token0][token1] = pairAddress;
        pairs[token1][token0] = pairAddress;

        emit CreatePair(pairAddress, token0, token1);

        return pairAddress;
    }

    function getPair(
        address tokenA,
        address tokenB
    ) public view returns (address) {
        return pairs[tokenA][tokenB];
    }
}
