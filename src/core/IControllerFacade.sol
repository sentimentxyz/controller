// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "./IController.sol";

interface IControllerFacade {
    function isTokenAllowed(address token) external view returns (bool);
    function canCall(address target, bytes4 sig) external view returns (bool);
    function canApprove(address target) external view returns (bool);
}
