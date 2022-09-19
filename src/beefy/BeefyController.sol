// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IController} from "../core/IController.sol";
import {IVault} from "./IVault.sol";

/**
    @title Beefy Vault (V6 and V7) controller
    @notice Controller for interacting with beefy vaults (V6 and V7)
*/
contract BeefyController is IController {

    /* -------------------------------------------------------------------------- */
    /*                              CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice deposit(uint256)
    bytes4 constant DEPOSIT = 0xb6b55f25;

    /// @notice depositAll()
    bytes4 constant DEPOSIT_ALL = 0xde5f6268;

    /// @notice withdraw(uint256)
    bytes4 constant WITHDRAW = 0x2e1a7d4d;

    /// @notice withdrawAll()
    bytes4 constant WITHDRAW_ALL = 0x853828b6;

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    /// @dev Controller logic does not need to verify the address of inbound or
    /// outbound tokens against isTokenAllowed since the target address corresponds
    /// to the vault itself and each beefy vault only deals with two unique tokens
    function canCall(address target, bool, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);
        if (sig == DEPOSIT || sig == DEPOSIT_ALL) {
            address[] memory tokensIn = new address[](1);
            address[] memory tokensOut = new address[](1);
            tokensIn[0] = target;
            tokensOut[0] = IVault(target).want();
            return (true, tokensIn, tokensOut);
        }
        if (sig == WITHDRAW || sig == WITHDRAW_ALL) {
            address[] memory tokensIn = new address[](1);
            address[] memory tokensOut = new address[](1);
            tokensIn[0] = IVault(target).want();
            tokensOut[0] = target;
            return (true, tokensIn, tokensOut);
        }

        return (false, new address[](0), new address[](0));
    }
}