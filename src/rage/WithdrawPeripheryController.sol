// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";

/**
    @title Rage Trade delta netural gmx vault controller
*/
contract WithdrawPeripheryController is IController {
    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice redeemToken(address,address,uint256)
    bytes4 constant REDEEM = 0x0d71bdc3;

    /// @notice withdrawToken(address,address,uint256)
    bytes4 constant WITHDRAW = 0x01e33667;

    /// @notice rage trade delta netural jr vault
    address[] public vault;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @param _vault rage trade delta netural jr vault
    */
    constructor(address _vault) {
        vault.push(_vault);
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(
        address,
        bool,
        bytes calldata data
    )
        external
        view
        returns (
            bool,
            address[] memory,
            address[] memory
        )
    {
        bytes4 sig = bytes4(data);

        if (sig == REDEEM || sig == WITHDRAW) {
            (address token, , ) = abi.decode(
                data[4:],
                (address, address, uint256)
            );

            address[] memory tokensIn = new address[](1);
            tokensIn[0] = token;

            return (true, tokensIn, vault);
        }

        return (false, new address[](0), new address[](0));
    }
}
