// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {ControllerFacade} from "../../core/ControllerFacade.sol";

contract TestBase is Test {

    ControllerFacade controllerFacade;

    function setUp() virtual public {
        controllerFacade = new ControllerFacade();
    }
}