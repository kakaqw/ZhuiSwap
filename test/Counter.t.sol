// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ZhuiswapPair} from "../src/Zhuiswap-Pair.sol";

// import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    function setUp() public {
        zhuiswapPair = new ZhuiswapPair();
    }

    function testMint() public {}
}
