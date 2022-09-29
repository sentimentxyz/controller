// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";

/**
    @title WETH Controller
    @notice Controller for Interacting with Wrapped Ether contract
    arbi:0x82aF49447D8a07e3bd95BD0d56f35241523fBab1
*/
contract WETHController is IController {

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice deposit() function signature
    bytes4 constant DEPOSIT = 0xd0e30db0;

    /// @notice withdraw(uint256) function signature
    bytes4 constant WITHDRAW = 0x2e1a7d4d;

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice List of tokens
    /// @dev Will always have one token WETH
    address[] public weth;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param wEth address of WETH
    */
    constructor(address wEth) {
        weth.push(wEth);
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(
        address,
        bool,
        bytes calldata data
    ) external view returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);
        if(sig == DEPOSIT) return (true, weth, new address[](0));
        if(sig == WITHDRAW) return (true, new address[](0), weth);
        return (false, new address[](0), new address[](0));
    }
}