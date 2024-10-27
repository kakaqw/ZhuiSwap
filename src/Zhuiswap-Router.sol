// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Zhuiswap-Pair.sol";
import "./Zhuiswap-Factory.sol";
import "./interface/IZhuiswap-Pair.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ZhuiswapRouter {
    emit transfer(address indexed from, address indexed to, uint256 value);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 amountlptokenMin
    ) public {
        //查询池子是否存在
        address pool = getPair(tokenA, tokenB);
        require(pool != address(0), "Router: Pool does not exist");

        //进行授权
        IERC20(tokenB).approve(address(this), amountB);
        IERC20(tokenB).approve(address(this), amountB);

        //将token转移到路由合约
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        //向池子转移token
        IERC20(tokenA).transfer(pool, amountA);
        IERC20(tokenB).transfer(pool, amountB);

        //mint Lp token凭证
        (bool success, uint256 lpAmount) = IZhuiswapPair(pool).mint();
        require(lpAmount >= amountlptokenMin, "Router: Insufficient liquidity");

        //想msg.sender转移Lp token
        IERC20(pool).transfer(msg.sender, lpAmount);

        emit transfer(address(0), msg.sender, lpAmount);
    }

    function removeLiquidity() public {}

    function swap() public {}
}
