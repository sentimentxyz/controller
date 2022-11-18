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

    /// @notice index of token in coins[]
    uint immutable TOKEN_INDEX;

    /// @notice non eth token in pool
    address[] token;

    /// @notice pool LP token
    address[] lpToken;

    /// @notice exchange(int128,int128,uint256,uint256)	function signature
    bytes4 public constant EXCHANGE = 0x3df02124;

    /// @notice add_liquidity(uint256[2],uint256) function signature
    bytes4 public constant ADD_LIQUIDITY = 0x0b4c7e4d;

    /// @notice remove_liquidity(uint256,uint256[2]) function signature
    bytes4 public constant REMOVE_LIQUIDITY = 0x5b36389c;

    /// @notice remove_liquidity_one_coin(uint256,int128,uint256) function signature
    bytes4 public constant REMOVE_LIQUIDITY_ONE_COIN = 0x1a4d01d2;

    constructor(uint tokenIndex, IStableSwapPool pool) {
        TOKEN_INDEX = tokenIndex;
        lpToken.push(pool.lp_token());
        token.push(pool.coins(TOKEN_INDEX));
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address, bool useEth, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        if (sig == ADD_LIQUIDITY) return canAddLiquidity(data);
        if (sig == REMOVE_LIQUIDITY_ONE_COIN)
            return canRemoveLiquidityOneCoin(data);
        if (sig == REMOVE_LIQUIDITY) return canRemoveLiquidity();
        if (sig == EXCHANGE) return canExchange(useEth);

        return (false, new address[](0), new address[](0));
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    function canAddLiquidity(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (uint[2] memory amounts) = abi.decode(data[4:], (uint[2]));

        if (amounts[TOKEN_INDEX] > 0) {
            return (true, lpToken, token);
        }

        return (true, lpToken, new address[](0));
    }

    function canRemoveLiquidityOneCoin(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (,int128 i, uint256 min_amount) = abi.decode(
            data[4:],
            (uint256, int128, uint256)
        );

        if (min_amount == 0)
            return (false, new address[](0), new address[](0));

        if (TOKEN_INDEX == uint128(i)) {
            return (true, token, lpToken);
        }

        return (true, new address[](0), lpToken);
    }

    function canRemoveLiquidity()
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        return (true, token, lpToken);
    }

    function canExchange(bool useEth)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        if (useEth) {
            return (
                true,
                token,
                new address[](0)
            );
        }

        return (
            true,
            new address[](0),
            token
        );
    }
}