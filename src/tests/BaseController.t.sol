// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console2.sol";
import {TestBase} from "./utils/Base.t.sol";
import {BaseController} from "../core/BaseController.sol";

contract TestBaseControllerArbi is TestBase {

    BaseController baseController;

    address target = makeAddr("target");

    function setUp() override public {
        super.setUp();
        baseController = new BaseController();
        controllerFacade.updateController(target, baseController);
    }

    function testCannotCall(bytes calldata data) public {

        (bool canCall,,)
            = controllerFacade.canCall(target, false, data);

        assertFalse(canCall);
    }
}