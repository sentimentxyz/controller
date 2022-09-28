// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";

interface IYVault {
    function token() external view returns (address);
}

/**
    @title Yearn Vault Controller
    @notice Controller for Interacting with yearn vaults
    arbi:0x239e14A19DFF93a17339DCC444f74406C17f8E67
*/
contract YearnVaultController is IController {

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice deposit(uint256) function signature
    bytes4 constant DEPOSIT = 0xb6b55f25;

    /// @notice withdraw(uint256) function signature
    bytes4 constant WITHDRAW = 0x2e1a7d4d;

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

        if (sig == DEPOSIT) {
            address[] memory tokensIn = new address[](1);
            address[] memory tokensOut = new address[](1);

            tokensIn[0] = target;
            tokensOut[0] = IYVault(target).token();

            return (true, tokensIn, tokensOut);
        }
        if (sig == WITHDRAW) {
            address[] memory tokensIn = new address[](1);
            address[] memory tokensOut = new address[](1);

            tokensOut[0] = target;
            tokensIn[0] = IYVault(target).token();

            return (true, tokensIn, tokensOut);
        }

        return (false, new address[](0), new address[](0));
    }
}