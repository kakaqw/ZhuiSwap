// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Zhuiswap-Pair.sol";
import "./Zhuiswap-Factory.sol";
import "./interface/IZhuiswap-factory.sol";
import "./interface/IZhuiswap-Pair.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./library/math.sol";

contract ZhuiswapRouter {
    address public immutable factory;

    event Transfer(
        address token,
        address indexed from,
        address indexed to,
        uint256 value
    );

    constructor(address _factory) {
        factory = _factory;
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 amountlptokenMin
    ) public {
        //查询池子是否存在
        address pool = IZhuiswapFactory(factory).getPair(tokenA, tokenB);
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

        emit Transfer(pool, address(this), msg.sender, lpAmount);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        address lpToken,
        uint256 lpAmount
    ) public {
        //查询池子是否存在
        address pool = IZhuiswapFactory(factory).getPair(tokenA, tokenB);
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

        //向msg.sender转移token
        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        emit Transfer(tokenA, address(this), msg.sender, amountA);
        emit Transfer(tokenB, address(this), msg.sender, amountB);
    }

    function swap(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 minoutputAmount
    ) public {
        //通过factory查看池子是否存在
        address pool = IZhuiswapFactory(factory).getPair(
            inputToken,
            outputToken
        );
        require(pool != address(0), "Router: Pool does not exist");

        //检查是否有授权
        uint256 approveToken = IERC20(inputToken).allowance(msg.sender, pool);
        require(approveToken >= inputAmount, "Router: Insufficient allowance");

        //获取池子token储备
        uint256 poolReserveA = IERC20(inputToken).balanceOf(pool);
        uint256 poolReserveB = IERC20(outputToken).balanceOf(pool);

        //计算output值
        uint256 outputValue = math.getAmountOut(
            poolReserveA,
            poolReserveB,
            inputAmount,
            minoutputAmount
        );

        //转移token
        IERC20(inputToken).transferFrom(msg.sender, pool, inputAmount);

        //开始交易
        IZhuiswapPair(pool).swap(minoutputAmount, msg.sender);
    }
}
