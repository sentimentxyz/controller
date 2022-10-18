// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Ownable} from "../utils/Ownable.sol";
import {IController} from "./IController.sol";
import {IControllerFacade} from "./IControllerFacade.sol";

/**
    @title Controller Facade
    @notice This contract acts as a single interface for the client to determine
    if a given interactions is acceptable
*/
contract ControllerFacade is Ownable, IControllerFacade {

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// Mapping that returns if a given token is supported by the protocol
    mapping(address => bool) public isTokenAllowed;

    /// Mapping of external interaction with respective controller
    mapping(address => IController) public controllerFor;

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    event UpdateController(address indexed target, address indexed controller);

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract Constructor
    */
    constructor() Ownable(msg.sender) {}

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IControllerFacade
    function canCall(
        address target,
        bool useEth,
        bytes calldata data
    )
        external
        view
        returns (bool isValid, address[] memory tokensIn, address[] memory tokensOut)
    {
        (isValid, tokensIn, tokensOut) = controllerFor[target].canCall(target, useEth, data);
        if (isValid) isValid = validateTokensIn(tokensIn);
    }

    /* -------------------------------------------------------------------------- */
    /*                              INTERNAL FUNCTIONS                            */
    /* -------------------------------------------------------------------------- */

    function validateTokensIn(address[] memory tokensIn)
        internal
        view
        returns (bool)
    {
        for (uint i; i < tokensIn.length; i++)
            if (!isTokenAllowed[tokensIn[i]]) return false;
        return true;
    }


    /* -------------------------------------------------------------------------- */
    /*                               ADMIN FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    function updateController(address target, IController controller)
        external
        adminOnly
    {
        controllerFor[target] = controller;
        emit UpdateController(target, address(controller));
    }

    function toggleTokenAllowance(address token) external adminOnly {
        isTokenAllowed[token] = !isTokenAllowed[token];
    }
}
