// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "src/core/IController.sol";
import "./IERC4626.sol";

contract ERC4626Controller is IController {

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    bytes4 constant DEPOSIT = 0x6e553f65;
    bytes4 constant MINT = 0x94bf804d;
    bytes4 constant REDEEM = 0xba087652;
    bytes4 constant WITHDRAW = 0xb460af94;

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address target, bool, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        if (sig == DEPOSIT || sig == MINT) {
            address[] memory tokensIn = new address[](1);
            address[] memory tokensOut = new address[](1);
            tokensIn[0] = target;
            tokensOut[0] = IERC4626(target).asset();
            return (true, tokensIn, tokensOut);
        }

        if (sig == REDEEM || sig == WITHDRAW) {
            address[] memory tokensIn = new address[](1);
            address[] memory tokensOut = new address[](1);
            tokensIn[0] = IERC4626(target).asset();
            tokensOut[0] = target;
            return (true, tokensIn, tokensOut);
        }

        return (false, new address[](0), new address[](0));
    }
}