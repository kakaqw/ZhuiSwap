// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IZhuiswapPair {
    function mint() external returns (bool, uint256);

    function burn() external returns (bool);

    function updateReserve() external;

    function getReserve() external view returns (uint256, uint256);

    function swap(
        uint256 minOutputAmount,
        address to
    ) external returns (uint256);
}
