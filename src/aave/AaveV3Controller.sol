// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {IController} from "../core/IController.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";
import {IPoolV3} from "./IPoolV3.sol";

/**
    @title Aave V3 controller
    @notice Controller for aave v3 interaction
    arbi:0x794a61358D6845594F94dc1DB02A252b5b4814aD
*/
contract AaveV3Controller is IController {

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice supply(address,uint256,address,uint16) function signature
    bytes4 public constant SUPPLY = 0x617ba037;

    /// @notice withdraw(address,uint256,address) function signature
    bytes4 public constant WITHDRAW = 0x69328dec;

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice IControllerFacade
    IControllerFacade public immutable controllerFacade;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract Constructor
        @param _controller Address of controller facade
    */
    constructor(IControllerFacade _controller) {
        controllerFacade = _controller;
    }

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
        if (sig == SUPPLY) {
            address asset = abi.decode(
                data[4:],
                (address)
            );
            address[] memory tokensIn = new address[](1);
            address[] memory tokensOut = new address[](1);
            tokensIn[0] = IPoolV3(target).getReserveData(asset).aTokenAddress;
            tokensOut[0] = asset;
            return (
                controllerFacade.isTokenAllowed(tokensIn[0]),
                tokensIn,
                tokensOut
            );
        }
        if (sig == WITHDRAW) {
            address asset = abi.decode(
                data[4:],
                (address)
            );
            address[] memory tokensIn = new address[](1);
            address[] memory tokensOut = new address[](1);
            tokensIn[0] = asset;
            tokensOut[0] = IPoolV3(target).getReserveData(asset).aTokenAddress;
            return (true, tokensIn, tokensOut);
        }
        return (false, new address[](0), new address[](0));
    }
}