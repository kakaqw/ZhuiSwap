// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./library/math.sol";

contract ZhuiswapPair {
    uint256 private constant MINIMUM_LIQUIDITY = 1000;

    //池子的两种token
    address public tokenA;
    address public tokenB;

    //池子token储备
    uint256 public reserveA;
    uint256 public reserveB;

    event Mint(address indexed sender, uint256 indexed amount);
    event Burn(address indexed sender, uint256 indexed amountA);

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
        if (LpTokenSupply == 0) {
            liquidity = sqrt(amountA * amountB) - MINIMUM_LIQUIDITY;
            _mint(address(this), MINIMUM_LIQUIDITY);
        } else {
            liquidity = Math.min(
                (amountA * totalSupply()) / reserveA,
                (amountB * totalSupply()) / reserveB
            );
        }

        //为调用者mint Lp token
        _mint(msg.sender, liquidity);
        LpTokenSupply += liquidity;

        //更新储备
        updateReserve();

        emit Mint(msg.sender, liquidity);

        return (ture, liquidity0);
    }

    // 撤池子
    function burn() public returns (bool) {
        //获取Lp代币持有者的Lp代币数量
        uint256 liquidity = balanceOf(msg.sender);

        //计算LP持有者对应的token数量
        uint256 amountA = (liquidity * reserveA) / totalSupply();
        uint256 amountB = (liquidity * reserveB) / totalSupply();

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

    //更新储备
    function updateReserve() public {
        reserveA = IERC20(tokenA).balanceOf(address(this));
        reserveb = IERC20(tokenB).balanceOf(address(this));
    }
}
