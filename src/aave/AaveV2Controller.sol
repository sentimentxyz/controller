// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {IController} from "../core/IController.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";
import {IProtocolDataProvider} from "./IProtocolDataProvider.sol";

contract AaveV2Controller is IController {
    bytes4 public constant DEPOSIT = 0xe8eda9df;
    bytes4 public constant WITHDRAW = 0x69328dec;

    IProtocolDataProvider public dataProvider;
    IControllerFacade public controllerFacade;

    constructor(
        IControllerFacade _controller,
        IProtocolDataProvider _dataProvider
    ) 
    {
        controllerFacade = _controller;
        dataProvider = _dataProvider;
    }

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
                controllerFacade.isSwapAllowed(tokensIn[0]),
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