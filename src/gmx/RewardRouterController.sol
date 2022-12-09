// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";

/**
    @title Reward Router Controller for claiming and compounding rewards
    @dev arbi:0xA906F338CB21815cBc4Bc87ace9e68c87eF8d8F1
*/
contract RewardRouterController is IController {

    /* -------------------------------------------------------------------------- */
    /*                              STORAGE VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice compound()
    bytes4 constant compound = 0xf69e2046;

    /// @notice claimFees()
    bytes4 constant claimFees = 0xd294f093;

    /// @notice WETH
    address[] WETH;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    constructor(address _WETH) {
        WETH.push(_WETH);
    }

    /* -------------------------------------------------------------------------- */
    /*                             EXTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    function canCall(address, bool, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        if (sig == compound) return canCallCompound();
        if (sig == claimFees) return canCallClaimFees();

        return (false, new address[](0), new address[](0));
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    function canCallClaimFees()
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        return (true, WETH, new address[](0));
    }

    function canCallCompound()
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        return (true, WETH, new address[](0));
    }
}