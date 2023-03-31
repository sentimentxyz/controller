// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "./IController.sol";

interface IControllerFacade {
    function controllerFor(address target) external view returns (IController);
    function isTokenAllowed(address token) external view returns (bool);
    function canCall(address target, bytes4 sig) external view returns (bool);
    function canApprove(address target) external view returns (bool);
    function canCall(address target, bool useEth, bytes calldata data)
        external
        view
        returns (bool isValid, address[] memory tokensIn, address[] memory tokensOut);
}
