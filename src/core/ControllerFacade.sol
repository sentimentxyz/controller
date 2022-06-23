// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Ownable} from "../utils/Ownable.sol";
import {IController} from "./IController.sol";
import {IControllerFacade} from "./IControllerFacade.sol";

contract ControllerFacade is Ownable, IControllerFacade {
    mapping(address => bool) public isTokenAllowed;
    mapping(address => IController) public controllerFor;

    event UpdateController(address indexed target, address indexed controller);

    constructor() Ownable(msg.sender) {}

    function canCall(
        address target,
        bool useEth,
        bytes calldata data
    ) external view returns (bool, address[] memory, address[] memory) {
        return controllerFor[target].canCall(target, useEth, data);
    }

    // Admin Only
    function updateController(address target, IController controller)
        external
        adminOnly
    {
        controllerFor[target] = controller;
        emit UpdateController(target, address(controller));
    }

    function toggleTokenAllowance(address token) external adminOnly {
        isTokenAllowed[token] = !isTokenAllowed[token];
    }
}
