// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";
import {ITransformERC20Feature} from "./ITransform.sol";

/**
 * @title 0x V4 Controller
 *     @notice 0x v4 controller for transformERC20
 */
contract TransformController is IController {
    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice transformERC20(address, address, uint256, uint256, (uint32,bytes)[])
    bytes4 constant TRANSFORMERC20 = 0x415565b0;

    /// @notice ETH address
    address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /* -------------------------------------------------------------------------- */
    /*                              EXTERNAL FUNCTIONS                            */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address, bool, bytes calldata data)
        external
        pure
        returns (bool, address[] memory tokensIn, address[] memory tokensOut)
    {
        bytes4 sig = bytes4(data);

        if (sig != TRANSFORMERC20) {
            return (false, new address[](0), new address[](0));
        }

        (address tokenOut, address tokenIn) =
            abi.decode(data[4:], (address, address));

        if (tokenIn == ETH) {
            tokensOut = new address[](1);
            tokensOut[0] = tokenOut;
            return (true, new address[](0), tokensOut);
        }

        if (tokenOut == ETH) {
            tokensIn = new address[](1);
            tokensIn[0] = tokenIn;
            return (true, tokensIn, new address[](0));
        }

        tokensIn = new address[](1);
        tokensOut = new address[](1);

        tokensIn[0] = tokenIn;
        tokensOut[0] = tokenOut;

        return (true, tokensIn, tokensOut);
    }
}
