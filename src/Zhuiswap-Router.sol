// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Zhuiswap-Pair.sol";
import "./Zhuiswap-Factory.sol";
import "./interface/IZhuiswap-Pair.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ZhuiswapRouter {
    event Transfer(
        address token,
        address indexed from,
        address indexed to,
        uint256 value
    );

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

        //向msg.sender转移Lp token
        IERC20(pool).transfer(msg.sender, lpAmount);

        emit transfer(pool, address(this), msg.sender, lpAmount);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        address lpToken,
        uint256 lpAmount
    ) public {
        //查询池子是否存在
        address pool = getPair(tokenA, tokenB);
        require(pool != address(0), "Router: Pool does not exist");

        // 检查授权Lp token
        require(
            IERC20(pool).allowance(msg.sender, address(this)) >= lpAmount,
            "Router: Insufficient allowance"
        );

        //将Lp token转移到pair合约
        IERC20(lpToken).transferFrom(msg.sender, address(this), lpAmount);

        //调用销毁
        IZhuiswapPair(pool).burn();

        //获取撤出的token数量
        uint256 amountA = IERC20(tokenA).balanceOf(address(this));
        uint256 amountB = IERC20(tokenB).balanceOf(address(this));

        //想msg.sender转移token
        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        emit Transfer(tokenA, address(this), msg.sender, amountA);
        emit Transfer(tokenB, address(this), msg.sender, amountb);
    }

    function swap() public {}
}
