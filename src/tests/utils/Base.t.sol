// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "src/core/ControllerFacade.sol";

contract TestBase is Test {

    ControllerFacade controllerFacade;

    function setupControllerFacade() public {
        controllerFacade = new ControllerFacade();
    }
}