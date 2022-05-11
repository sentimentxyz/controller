// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IController} from "./IController.sol";

interface IControllerFacade {
    function isTokenAllowed(address token) external view returns (bool);
    function controllerFor(address target) external view returns (IController);

    function canCall(
        address target,
        bool useEth,
        bytes calldata data
    ) external view returns (bool, address[] memory, address[] memory);

    function canCallBatch(
        address[] calldata target,
        bool[] calldata useEth,
        bytes[] calldata data
    ) external view returns (bool, address[] memory, address[] memory);
}
