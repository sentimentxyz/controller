// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test} from "forge-std/Test.sol";
import {ControllerFacade} from "src/core/ControllerFacade.sol";

contract TestBase is Test {

    ControllerFacade controllerFacade;

    function setupControllerFacade() public {
        controllerFacade = new ControllerFacade();
    }
}