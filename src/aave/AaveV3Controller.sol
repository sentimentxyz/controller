// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {IController} from "../core/IController.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";
import {IPoolV3} from "./IPoolV3.sol";

contract AaveV3Controller is IController {
    bytes4 public constant SUPPLY = 0x617ba037;
    bytes4 public constant WITHDRAW = 0x69328dec;

    IControllerFacade public controllerFacade;

    constructor(IControllerFacade _controller) {
        controllerFacade = _controller;
    }

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
            tokensOut[0] = IPoolV3(target).getReserveData(asset).aTokenAddress;
            return (true, tokensIn, tokensOut);
        }
        return (false, new address[](0), new address[](0));
    }
}