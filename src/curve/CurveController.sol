// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IController} from "../core/IController.sol";
import {IStableSwapPool} from "./IStableSwapPool.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";

contract CurveController is IController {
    IControllerFacade public immutable controllerFacade;
    bytes4 public constant EXCHANGE = 0x5b41b908;

    constructor(IControllerFacade _controllerFacade) {
        controllerFacade = _controllerFacade;
    }

    function canCall(
        address target,
        bytes calldata data
    ) external view returns (bool, address[] memory, address[] memory)  
    {        
        if (bytes4(data) != EXCHANGE) 
            return (false, new address[](0), new address[](0));

        (uint256 i, uint256 j) = abi.decode(data[4:], (uint256, uint256));

        // Prepare Output
        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](1);
        tokensOut[0] = IStableSwapPool(target).coins(i);
        tokensIn[0] = IStableSwapPool(target).coins(j);
        
        return (
            controllerFacade.isSwapAllowed(tokensIn[0]), 
            tokensIn, 
            tokensOut
        );
    }
}