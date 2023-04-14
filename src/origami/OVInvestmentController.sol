// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";
import {IOrigamiInvestment} from "./IOrigamiInvestment.sol";

/**
 * @title Origami Investment vault controller
 */
contract OVInvestmentController is IController {
    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice investWithToken(tuple quoteData)
    bytes4 constant INVEST = 0xff32b55c;

    /// @notice exitToToken(tuple quoteData,address recipient)
    bytes4 constant EXIT = 0xf57092bd;

    /// @notice investWithNative(tuple quoteData)
    bytes4 constant INVEST_NATIVE = 0x27e66c62;

    /// @notice exitToNative(tuple quoteData,address recipient)
    bytes4 constant EXIT_NATIVE = 0xd8e5db52;

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address target, bool, bytes calldata data)
        external
        pure
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        if (sig == INVEST) {
            return canInvest(target, data[4:]);
        } else if (sig == EXIT) {
            return canExit(target, data[4:]);
        } else if (sig == INVEST_NATIVE) {
            return canInvestWithNative(target);
        } else if (sig == EXIT_NATIVE) {
            return canExitWithNative(target);
        }

        return (false, new address[](0), new address[](0));
    }

    function canInvest(address target, bytes calldata data)
        internal
        pure
        returns (bool, address[] memory tokensIn, address[] memory tokensOut)
    {
        IOrigamiInvestment.InvestQuoteData memory params = abi.decode(data, (IOrigamiInvestment.InvestQuoteData));

        tokensIn = new address[](1);
        tokensIn[0] = target;
        tokensOut = new address[](1);
        tokensOut[0] = params.fromToken;

        return (true, tokensIn, tokensOut);
    }

    function canInvestWithNative(address target)
        internal
        pure
        returns (bool, address[] memory tokensIn, address[] memory)
    {
        tokensIn = new address[](1);
        tokensIn[0] = target;

        return (true, tokensIn, new address[](0));
    }

    function canExit(address target, bytes calldata data)
        internal
        pure
        returns (bool, address[] memory tokensIn, address[] memory tokensOut)
    {
        (IOrigamiInvestment.ExitQuoteData memory params,) = abi.decode(data, (IOrigamiInvestment.ExitQuoteData, address));

        tokensIn = new address[](1);
        tokensIn[0] = params.toToken;
        tokensOut = new address[](1);
        tokensOut[0] = target;

        return (true, tokensIn, tokensOut);
    }

    function canExitWithNative(address target)
        internal
        pure
        returns (bool, address[] memory, address[] memory tokensOut)
    {
        tokensOut = new address[](1);
        tokensOut[0] = target;

        return (true, new address[](0), tokensOut);
    }
}
