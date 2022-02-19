// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Ownable} from "../utils/Ownable.sol";
import {IController} from "./IController.sol";
import {IControllerFacade} from "./IControllerFacade.sol";

contract ControllerAggregator is Ownable, IControllerFacade {
    mapping(address => bool) public isSwapAllowed;
    mapping(address => IController) public controllerFor;

    event UpdateController(address indexed target, address indexed controller);
    
    constructor() Ownable(msg.sender) {}

    function canCall(
        address target,
        bytes calldata data
    ) external view returns (bool, address[] memory, address[] memory) {
        return controllerFor[target].canCall(target, data);
    }

    function canCallBatch(
        address[] calldata target,
        bytes[] calldata data
    ) external view returns (bool, address[] memory, address[] memory) {
        uint lenMinusOne = target.length - 1;

        for(uint i = 0; i < lenMinusOne; ++i) {
            if(address(controllerFor[target[i]]) == address(0))
                return(false, new address[](0), new address[](0));
        }

        return controllerFor[target[lenMinusOne]].canCall(target[lenMinusOne], data[lenMinusOne]);
    }

    // Admin Only
    function updateController(address target, IController controller) external adminOnly {
        controllerFor[target] = controller;
        emit UpdateController(target, address(controller));
    }

    function toggleSwapAllowance(address token) external adminOnly {
        isSwapAllowed[token] = !isSwapAllowed[token];
    }
}
