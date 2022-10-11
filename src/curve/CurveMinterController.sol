// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IController} from "../core/IController.sol";

/**
    @title Curve Minter Controller
    @notice Interaction controller for curve minter
*/
contract CurveMinterController is IController {

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice mint(address)
    bytes4 constant MINT = 0x6a627842;

    /// @notice curve gov token
    address[] crv;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _crv Address of curve gov token
    */
    constructor(address _crv) {
        crv.push(_crv);
    }

    /* -------------------------------------------------------------------------- */
    /*                             EXTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address, bool, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        if (bytes4(data) == MINT) {
            return (true, crv, new address[](0));
        }
        return (false, new address[](0), new address[](0));
    }
}