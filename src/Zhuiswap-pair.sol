// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
// import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./library/math.sol";

contract ZhuiswapPair is ERC20 {
    uint256 private constant MINIMUM_LIQUIDITY = 1000;

    //池子的两种token
    address public tokenA;
    address public tokenB;

    //池子token储备
    uint256 public reserveA;
    uint256 public reserveB;

    event Mint(address indexed sender, uint256 indexed amount);
    event Burn(address indexed sender, uint256 indexed amountA);
    event Swap(uint256 inputAmount, uint256 outputAmount, address indexed to);

    constructor(address _tokenA, address _tokenB) ERC20("ZhuiswapPair", "ZLP") {
        require(_tokenA != _tokenB, "Constructor: Identical token addresses");
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    //加池子
    function mint() public returns (bool, uint256) {
        //获取当前池子的token数量
        uint256 balanceOfA = IERC20(tokenA).balanceOf(address(this));
        uint256 balanceOfB = IERC20(tokenB).balanceOf(address(this));

        //计算新加入的token数量
        uint256 amountA = balanceOfA - reserveA;
        uint256 amountB = balanceOfB - reserveB;

        uint256 liquidity;
        uint256 totalSupply = totalSupply();
        if (totalSupply == 0) {
            liquidity = math.sqrt(amountA * amountB) - MINIMUM_LIQUIDITY;
            _mint(address(this), MINIMUM_LIQUIDITY);
        } else {
            liquidity = math.min(
                (amountA * totalSupply) / reserveA,
                (amountB * totalSupply) / reserveB
            );
        }

        //为调用者mint Lp token
        _mint(msg.sender, liquidity);

        //更新储备
        updateReserve();

        emit Mint(msg.sender, liquidity);

        // bool ture = true;

        return (true, liquidity);
    }

    // 撤池子
    function burn() public returns (bool) {
        //获取Lp代币持有者的Lp代币数量
        uint256 liquidity = IERC20(address(this)).balanceOf(msg.sender);

        //计算LP持有者对应的token数量
        uint256 amountA = (liquidity * reserveA) /
            IERC20(address(this)).totalSupply();
        uint256 amountB = (liquidity * reserveB) /
            IERC20(address(this)).totalSupply();

        //token转账
        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        //燃烧持有者的Lp代币
        _burn(msg.sender, liquidity);

        //更新储备
        updateReserve();

        emit Burn(msg.sender, liquidity);

        return true;
    }

    //swap函数
    function swap(
        uint256 minOutputAmount,
        address to
    ) public returns (uint256) {
        uint256 outputAmount;

        //此时储备还未更新
        (uint256 reserveTokenA, uint256 reserveTokenB) = getReserve();

        //利用未更新的储备计算转入的token和数量
        uint256 inputTokenA = IERC20(tokenA).balanceOf(address(this)) -
            reserveTokenA;
        uint256 inputTokenB = IERC20(tokenB).balanceOf(address(this)) -
            reserveTokenB;
        require(
            inputTokenA == 0 && inputTokenB == 0,
            "Pair: Insufficient liquidity"
        );

        // 如果转入的是tokenA,则转出tokenB
        if (inputTokenA > 0) {
            outputAmount = math.getAmountOut(
                IERC20(tokenA).balanceOf(address(this)),
                IERC20(tokenB).balanceOf(address(this)),
                inputTokenA,
                minOutputAmount
            );

            require(outputAmount >= minOutputAmount, "amount is too small");
            IERC20(tokenB).transfer(to, outputAmount);

            updateReserve();

            emit Swap(inputTokenA, outputAmount, to);
        }

        //如果转入的是tokenB,则转出tokenA
        if (inputTokenB > 0) {
            outputAmount = math.getAmountOut(
                IERC20(tokenB).balanceOf(address(this)),
                IERC20(tokenA).balanceOf(address(this)),
                inputTokenB,
                minOutputAmount
            );

            require(outputAmount >= minOutputAmount, "amount is too small");
            IERC20(tokenA).transfer(to, outputAmount);

            updateReserve();

            emit Swap(inputTokenB, outputAmount, to);
        }
        return outputAmount;
    }

    //更新储备
    function updateReserve() public {
        reserveA = IERC20(tokenA).balanceOf(address(this));
        reserveB = IERC20(tokenB).balanceOf(address(this));
    }

    //返回储备
    function getReserve() public view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }
}
