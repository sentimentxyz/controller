// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IController} from "../core/IController.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";
import {IProtocolDataProvider} from "./IProtocolDataProvider.sol";

/**
    @title Aave V2 controller
    @notice Controller for aave v2 interaction
    eth:0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9
*/
contract AaveV2Controller is IController {

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice deposit(address,uint256,address,uint16)	function signature
    bytes4 public constant DEPOSIT = 0xe8eda9df;

    /// @notice withdraw(address,uint256,address) function signature
    bytes4 public constant WITHDRAW = 0x69328dec;

    /* -------------------------------------------------------------------------- */
    /*                               STATE_VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /**
        @notice IProtocolDataProvider
        @dev https://docs.aave.com/developers/v/2.0/the-core-protocol/protocol-data-provider/iprotocoldataprovider
    */
    IProtocolDataProvider public immutable dataProvider;

    /// @notice IControllerFacade
    IControllerFacade public immutable controllerFacade;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _controller address of controller Facade
        @param _dataProvider address of aave v2 data provider
    */
    constructor(
        IControllerFacade _controller,
        IProtocolDataProvider _dataProvider
    )
    {
        controllerFacade = _controller;
        dataProvider = _dataProvider;
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
        if (sig == DEPOSIT) {
            address asset = abi.decode(
                data[4:],
                (address)
            );
            address[] memory tokensIn = new address[](1);
            address[] memory tokensOut = new address[](1);
            (tokensIn[0],,) = dataProvider.getReserveTokensAddresses(asset);
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
            (tokensOut[0],,) = dataProvider.getReserveTokensAddresses(asset);
            return (true, tokensIn, tokensOut);
        }
        return (false, new address[](0), new address[](0));
    }
}