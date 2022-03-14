// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IController} from "../core/IController.sol";
import {IStableSwapPool} from "./IStableSwapPool.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";

contract StableSwapController is IController {
    IControllerFacade public immutable controllerFacade;
    bytes4 public constant EXCHANGE = 0x3df02124;

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
        // TODO Save gas by directly decoding to uint and avoid casting later
        (int128 i, int128 j,,) = abi.decode(
            data[4:],
            (int128, int128, uint256, uint256)
        );

        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](1);
        tokensIn[0] = IStableSwapPool(target).coins(uint128(j));     
        tokensOut[0] = IStableSwapPool(target).coins(uint128(i));
        
        return (
            controllerFacade.isSwapAllowed(tokensIn[0]), 
            tokensIn, 
            tokensOut
        );
    }
}