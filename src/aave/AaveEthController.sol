// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";

/**
    @title Aave Eth Controller
    @notice Controller for aave Weth interaction
    arbi:0xC09e69E79106861dF5d289dA88349f10e2dc6b5C
*/
contract AaveEthController is IController {

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice depositETH(address,address,uint16) function signature
    bytes4 public constant DEPOSIT = 0x474cf53d;

    /// @notice withdrawETH(address,uint256,address) function signature
    bytes4 public constant WITHDRAW = 0x80500d20;

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice List of tokens
    /// @dev Will always have one token aave WETH
    address[] public tokens;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _aWeth address of aave WETH
    */
    constructor(address _aWeth) {
        tokens.push(_aWeth);
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
        if (sig == DEPOSIT) return (true, tokens, new address[](0));
        if (sig == WITHDRAW) return (true, new address[](0), tokens);
        return (false, new address[](0), new address[](0));
    }
}