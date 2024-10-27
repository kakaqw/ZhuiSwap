// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IZhuiswapPair {
    function mint() external returns (bool);

    function burn() external returns (bool);
}
