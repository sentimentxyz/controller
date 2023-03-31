// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Ownable} from "../utils/Ownable.sol";
import {IController} from "./IController.sol";

/**
 * @title Controller Facade
 *     @notice This contract acts as a single interface for the client to determine
 *     if a given interactions is acceptable
 */
contract ControllerFacade is Ownable {
    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// Mapping of external interaction with respective controller
    mapping(address => IController) public controllerFor;

    /// Mapping that returns if a given token is supported by the protocol
    mapping(address => bool) public isTokenAllowed;

    /// Mapping of external interaction with respective controller
    mapping(address => mapping(bytes4 => bool)) public isActionWhitelisted;

    /// Mapping of external approve interaction with respective controller
    mapping(address => bool) public isApproveAllowed;

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    event UpdateController(address indexed target, address indexed controller);
    event UpdateWhitelist(address indexed target, bytes4 sig, bool isWhitelisted);
    event UpdateApproval(address indexed target, bool isApproveAllowed);
    event UpdateTokenAllowance(address indexed token, bool isTokenAllowed);

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Contract Constructor
     */
    constructor() Ownable(msg.sender) {}

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    function canCall(address target, bool useEth, bytes calldata data)
        external
        view
        returns (bool isValid, address[] memory tokensIn, address[] memory tokensOut)
    {
        (isValid, tokensIn, tokensOut) = controllerFor[target].canCall(target, useEth, data);
        if (isValid) isValid = validateTokensIn(tokensIn);
    }

    function canCall(address target, bytes4 sig) external view returns (bool) {
        return isActionWhitelisted[target][sig];
    }

    function canApprove(address target) external view returns (bool) {
        return isApproveAllowed[target];
    }

    /* -------------------------------------------------------------------------- */
    /*                              INTERNAL FUNCTIONS                            */
    /* -------------------------------------------------------------------------- */

    function validateTokensIn(address[] memory tokensIn) internal view returns (bool) {
        for (uint256 i; i < tokensIn.length; i++) {
            if (!isTokenAllowed[tokensIn[i]]) return false;
        }
        return true;
    }

    /* -------------------------------------------------------------------------- */
    /*                               ADMIN FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    function updateWhitelist(address target, bytes4 sig, bool isWhitelisted) external adminOnly {
        isActionWhitelisted[target][sig] = isWhitelisted;
        emit UpdateWhitelist(target, sig, isWhitelisted);
    }

    function updateApproval(address target, bool isAllowed) external adminOnly {
        isApproveAllowed[target] = isAllowed;
        emit UpdateApproval(target, isAllowed);
    }

    function toggleTokenAllowance(address token) external adminOnly {
        isTokenAllowed[token] = !isTokenAllowed[token];
        emit UpdateTokenAllowance(token, isTokenAllowed[token]);
    }

    function updateController(address target, IController controller) external adminOnly {
        controllerFor[target] = IController(controller);
        emit UpdateController(target, address(controller));
    }
}
