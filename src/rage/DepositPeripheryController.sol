// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";

/**
    @title Rage Trade delta netural gmx vault controller
*/
contract DepositPeripheryController is IController {
    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice depositToken(address,address,uint256)
    bytes4 constant DEPOSIT = 0xfb0f97a8;

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
        if (bytes4(data) == DEPOSIT) {
            (address token, , ) = abi.decode(
                data[4:],
                (address, address, uint256)
            );

            address[] memory tokensOut = new address[](1);
            tokensOut[0] = token;

            return (true, vault, tokensOut);
        }

        return (false, new address[](0), new address[](0));
    }
}
