// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";

/**
    @title Plutus GLP Vault Controller
    @notice Controller for Interacting with plutus glp vault
*/
contract PLVGLPController is IController {

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice deposit(uint256) function signature
    bytes4 constant DEPOSIT = 0xb6b55f25;

    /// @notice depositAll() function signature
    bytes4 constant DEPOSIT_ALL = 0xde5f6268;

    /// @notice redeem(uint256) function signature
    bytes4 constant REDEEM = 0xdb006a75;

    /// @notice redeemAll() function signature
    bytes4 constant REDEEM_ALL = 0x2f4350c2;

    /// @notice Staked GLP: 0x5402B5F40310bDED796c7D0F3FF6683f5C0cFfdf
    address[] sGLP;

    /// @notice PLVGLP: 0x5326E71Ff593Ecc2CF7AcaE5Fe57582D6e74CFF1
    address[] PLVGLP;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    constructor(address _SGLP, address _PLVGLP) {
        sGLP.push(_SGLP);
        PLVGLP.push(_PLVGLP);
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address, bool, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        if (sig == DEPOSIT || sig == DEPOSIT_ALL) {
            return (true, PLVGLP, sGLP);
        }
        if (sig == REDEEM || sig == REDEEM_ALL) {
            return (true, sGLP, PLVGLP);
        }

        return (false, new address[](0), new address[](0));
    }
}