// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";
import {IStableSwapPool} from "./IStableSwapPool.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";

/**
    @title Curve Zap Crypto Swap Controller
    @notice Controller for curve crypto swap interaction via native eth token
*/
contract CurveZapCryptoSwapController is IController {

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice add_liquidity(uint256[3],uint256) function signature
    bytes4 public constant ADD_LIQUIDITY = 0x4515cef3;

    /// @notice remove_liquidity(uint256,uint256[3]) function signature
    bytes4 public constant REMOVE_LIQUIDITY = 0xecb586a5;

    /// @notice remove_liquidity_one_coin(uint256,uint256,uint256) function signature
    bytes4 public constant REMOVE_LIQUIDITY_ONE_COIN = 0xf1dc3cc9;

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

        if (sig == ADD_LIQUIDITY) return canAddLiquidity(target, useEth, data);
        if (sig == REMOVE_LIQUIDITY_ONE_COIN)
            return canRemoveLiquidityOneCoin(target, data);
        if (sig == REMOVE_LIQUIDITY) return canRemoveLiquidity(target);

        return (false, new address[](0), new address[](0));
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Evaluates whether protocol can add liquidity to the target contract
        @param target External protocol address
        @param data calldata of the interaction with the target address
        @return canCall Specifies if the interaction is accepted
        @return tokensIn List of tokens that the account will receive after the
        interactions
        @return tokensOut List of tokens that will be removed from the account
        after the interaction
    */
    function canAddLiquidity(address target, bool useEth, bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        if (!useEth) return (false, new address[](0), new address[](0));

        address[] memory tokensIn = new address[](1);
        tokensIn[0] = IStableSwapPool(target).token();

        uint i; uint j;
        (uint[3] memory amounts) = abi.decode(data[4:], (uint[3]));
        address[] memory tokensOut = new address[](2);
        while(i < 2) {
            if(amounts[i] > 0)
                tokensOut[j++] = IStableSwapPool(target).coins(i);
            unchecked { ++i; }
        }
        assembly { mstore(tokensOut, j) }

        return (true, tokensIn, tokensOut);
    }

    /**
        @notice Evaluates whether protocol can remove liquidity from the target contract
        @param target External protocol address
        @param data calldata of the interaction with the target address
        @return canCall Specifies if the interaction is accepted
        @return tokensIn List of tokens that the account will receive after the
        interactions
        @return tokensOut List of tokens that will be removed from the account
        after the interaction
    */
    function canRemoveLiquidityOneCoin(address target, bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (,uint256 i, uint256 min_amount) = abi.decode(
            data[4:],
            (uint256, uint256, uint256)
        );

        if (min_amount == 0)
            return (false, new address[](0), new address[](0));

        address[] memory tokensOut = new address[](1);
        tokensOut[0] = IStableSwapPool(target).token();

        // if eth is being removed
        if (i == 2) return (true, new address[](0), tokensOut);

        address[] memory tokensIn = new address[](1);
        tokensIn[0] = IStableSwapPool(target).coins(i);

        return (true, tokensIn, tokensOut);
    }

    /**
        @notice Evaluates whether protocol can remove liquidity from the target contract
        @param target External protocol address
        @return canCall Specifies if the interaction is accepted
        @return tokensIn List of tokens that the account will receive after the
        interactions
        @return tokensOut List of tokens that will be removed from the account
        after the interaction
    */
    function canRemoveLiquidity(address target)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        address[] memory tokensOut = new address[](1);
        tokensOut[0] = IStableSwapPool(target).token();

        address[] memory tokensIn = new address[](3);
        tokensIn[0] = IStableSwapPool(target).coins(0);
        tokensIn[1] = IStableSwapPool(target).coins(1);
        tokensIn[2] = IStableSwapPool(target).coins(2);

        return (true, tokensIn, tokensOut);
    }
}