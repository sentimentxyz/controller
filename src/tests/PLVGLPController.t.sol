// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {TestBase} from "./utils/Base.t.sol";
import {PLVGLPController} from "../plutus/PLVGLPController.sol";

contract TestPLVGLPControllerArbi is TestBase {

    PLVGLPController plvGLPController;

    address PLVGLP = makeAddr("PLVGLP");
    address SGLP = makeAddr("SGLP");
    address target = makeAddr("target");

    function setUp() override public {
        super.setUp();
        plvGLPController = new PLVGLPController(SGLP, PLVGLP);
        controllerFacade.updateController(target, plvGLPController);
    }

    function testCanDeposit() public {
        // Setup
        controllerFacade.toggleTokenAllowance(PLVGLP);

        bytes memory data = abi.encodeWithSelector(0xb6b55f25,
            0
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], PLVGLP);
        assertEq(tokensOut[0], SGLP);
    }

    function testCanDepositAll() public {
        // Setup
        controllerFacade.toggleTokenAllowance(PLVGLP);

        bytes memory data = abi.encodeWithSelector(0xde5f6268);

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], PLVGLP);
        assertEq(tokensOut[0], SGLP);
    }

    function testCannotDeposit() public {
        bytes memory data = abi.encodeWithSelector(0xb6b55f25,
            0
        );

        // Test
        (bool canCall,,)
            = controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(!canCall);
    }

    function testCannotDepositAll() public {
        bytes memory data = abi.encodeWithSelector(0xde5f6268);

        // Test
        (bool canCall,,)
            = controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(!canCall);
    }

    function testCanRedeem() public {
        // Setup
        controllerFacade.toggleTokenAllowance(SGLP);

        bytes memory data = abi.encodeWithSelector(0xdb006a75,
            0
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], SGLP);
        assertEq(tokensOut[0], PLVGLP);
    }

    function testCanRedeemAll() public {
        // Setup
        controllerFacade.toggleTokenAllowance(SGLP);

        bytes memory data = abi.encodeWithSelector(0x2f4350c2);

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], SGLP);
        assertEq(tokensOut[0], PLVGLP);
    }

    function testCannotRedeem() public {
        bytes memory data = abi.encodeWithSelector(0xdb006a75,
            0
        );

        // Test
        (bool canCall,,)
            = controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(!canCall);
    }

    function testCannotRedeemAll() public {
        bytes memory data = abi.encodeWithSelector(0x2f4350c2);

        // Test
        (bool canCall,,)
            = controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(!canCall);
    }
}