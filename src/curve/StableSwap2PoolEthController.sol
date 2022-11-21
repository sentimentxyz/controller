// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";
import {IStableSwapPool} from "./IStableSwapPool.sol";

/**
    @title Curve stable Swap Controller
    @notice Controller for curve stable swap
    arbi:0x6eB2dc694eB516B16Dc9FBc678C60052BbdD7d80
*/
contract StableSwap2PoolEthController is IController {

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    address immutable ETH;

    /// @notice exchange(int128,int128,uint256,uint256)	function signature
    bytes4 public constant EXCHANGE = 0x3df02124;

    /// @notice add_liquidity(uint256[2],uint256) function signature
    bytes4 public constant ADD_LIQUIDITY = 0x0b4c7e4d;

    /// @notice remove_liquidity(uint256,uint256[2]) function signature
    bytes4 public constant REMOVE_LIQUIDITY = 0x5b36389c;

    /// @notice remove_liquidity_one_coin(uint256,int128,uint256) function signature
    bytes4 public constant REMOVE_LIQUIDITY_ONE_COIN = 0x1a4d01d2;

    constructor(address _ETH) {
        ETH = _ETH;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address target, bool useEth, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        if (sig == ADD_LIQUIDITY) return canAddLiquidity(target, data);
        if (sig == REMOVE_LIQUIDITY_ONE_COIN)
            return canRemoveLiquidityOneCoin(target, data);
        if (sig == REMOVE_LIQUIDITY) return canRemoveLiquidity(target);
        if (sig == EXCHANGE) return canExchange(target, useEth, data);

        return (false, new address[](0), new address[](0));
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    function canAddLiquidity(address target, bytes calldata data)
        internal
        view
        returns (bool, address[] memory tokensIn, address[] memory tokensOut)
    {
        (uint[2] memory amounts) = abi.decode(data[4:], (uint[2]));

        tokensIn = new address[](1);
        tokensIn[0] = IStableSwapPool(target).lp_token();

        address coin;
        for(uint i; i<2; i++) {
            if (amounts[i] > 0) {
                coin = IStableSwapPool(target).coins(i);
                if (coin != ETH) {
                    tokensOut = new address[](1);
                    tokensOut[0] = coin;
                    return (true, tokensIn, tokensOut);
                }
            }
        }

        return (true, tokensIn, tokensOut);
    }

    function canRemoveLiquidityOneCoin(address target, bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory tokensOut)
    {
        (,int128 i, uint256 min_amount) = abi.decode(
            data[4:],
            (uint256, int128, uint256)
        );

        if (min_amount == 0)
            return (false, new address[](0), new address[](0));

        tokensOut = new address[](1);
        tokensOut[0] = IStableSwapPool(target).lp_token();

        address coin = IStableSwapPool(target).coins(uint128(i));
        if (ETH != coin) {
            address[] memory tokensIn = new address[](1);
            tokensIn[0] = coin;
            return (true, tokensIn, tokensOut);
        }

        return (true, new address[](0), tokensOut);
    }

    function canRemoveLiquidity(address target)
        internal
        view
        returns (bool, address[] memory tokensIn, address[] memory tokensOut)
    {
        tokensIn = new address[](1);
        tokensOut = new address[](1);

        tokensOut[0] = IStableSwapPool(target).lp_token();

        address coin;
        for(uint i; i<2; i++) {
            coin = IStableSwapPool(target).coins(i);
            if (coin != ETH) {
                tokensIn[0] = coin;
                return (true, tokensIn, tokensOut);
            }
        }

        return (false, tokensIn, tokensOut);
    }

    function canExchange(address target, bool useEth, bytes calldata data)
        internal
        view
        returns (bool, address[] memory tokensIn, address[] memory tokensOut)
    {
        (int128 i, int128 j,,) = abi.decode(
            data[4:],
            (int128, int128, uint256, uint256)
        );

        if (useEth) {
            tokensIn = new address[](1);
            tokensIn[0] = IStableSwapPool(target).coins(uint128(j));
            return (true, tokensIn, new address[](0));
        }

        address coinIn = IStableSwapPool(target).coins(uint128(j));
        if (coinIn == ETH) {
            tokensOut = new address[](1);
            tokensOut[0] = IStableSwapPool(target).coins(uint128(i));
            return (true, new address[](0), tokensOut);
        }

        tokensIn = new address[](1);
        tokensOut = new address[](1);
        tokensIn[0] = IStableSwapPool(target).coins(uint128(j));
        tokensOut[0] = IStableSwapPool(target).coins(uint128(i));

        return (
            true,
            tokensIn,
            tokensOut
        );
    }
}