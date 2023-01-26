// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";

/**
    @title Rage Trade delta netural gmx vault controller
*/
contract DNGMXVaultController is IController {

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice depositToken(address,address,uint256)
    bytes4 constant DEPOSIT = 0xfb0f97a8;

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
    function canCall(address, bool, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        if (sig == DEPOSIT) return canDeposit(data[4:]);
        if (sig == REDEEM || sig == WITHDRAW) return canWithdraw(data[4:]);

        return (false, new address[](0), new address[](0));
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    function canDeposit(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (address token,,) = abi.decode(
            data, (address, address, uint256)
        );

        address[] memory tokensOut = new address[](1);
        tokensOut[0] = token;

        return (true, vault, tokensOut);
    }

    function canWithdraw(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (address token,,) = abi.decode(
            data, (address, address, uint256)
        );

        address[] memory tokensIn = new address[](1);
        tokensIn[0] = token;

        return (true, tokensIn, vault);
    }
}