// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IController} from "../core/IController.sol";
import {IStableSwapPool} from "./IStableSwapPool.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";

contract CurveController is IController {
    IControllerFacade public immutable controllerFacade;
    bytes4 public constant EXCHANGE = 0x3df02124;

    constructor(IControllerFacade _controllerFacade) {
        controllerFacade = _controllerFacade;
    }

    function canCall(
        address target,
        bytes calldata data
    ) external view returns (bool, address[] memory, address[] memory)  
    {
        // Verify function selector
        if(bytes4(data) != EXCHANGE) return (false, new address[](0), new address[](0));

        // Extract addresses for swapped tokens
        (int128 i, int128 j) = abi.decode(data, (int128, int128));
        
        // Prepare Output
        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](1);
        tokensOut[0] = IStableSwapPool(target).coins(uint128(i));
        tokensIn[0] = IStableSwapPool(target).coins(uint128(j));
        
        return (
            controllerFacade.isSwapAllowed(tokensIn[0]), 
            tokensIn, 
            tokensOut
        );
    }
}