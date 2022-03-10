// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IController} from "../core/IController.sol";
import {IStableSwapPool} from "./IStableSwapPool.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";

contract CurveController is IController {
    IControllerFacade public immutable controllerFacade;
    bytes4 public constant EXCHANGE = 0x394747c5;

    constructor(IControllerFacade _controllerFacade) {
        controllerFacade = _controllerFacade;
    }

    function canCall(address target, bytes calldata data) 
        external
        view
        returns (bool, address[] memory, address[] memory)  
    {   
        // validate signature
        if (bytes4(data) != EXCHANGE)
            return (false, new address[](0), new address[](0));

        // decode data
        (uint256 i, uint256 j,,,bool useEth) = abi.decode(
            data[4:],
            (uint256, uint256, uint256, uint256, bool)
        );

        address[] memory tokensIn = new address[](1);
        tokensIn[0] = IStableSwapPool(target).coins(j);     
        
        if (useEth) 
            return (
                controllerFacade.isSwapAllowed(tokensIn[0]),
                tokensIn,
                new address[](0)
            );

        address[] memory tokensOut = new address[](1);
        tokensOut[0] = IStableSwapPool(target).coins(i);
        
        return (
            controllerFacade.isSwapAllowed(tokensIn[0]), 
            tokensIn, 
            tokensOut
        );
    }
}