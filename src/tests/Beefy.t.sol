// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestBase} from "./utils/Base.t.sol";
import {IVault} from "../beefy/IVault.sol";
import {BeefyController} from "../beefy/BeefyController.sol";

contract TestBeefyArbitrum is TestBase {

    BeefyController beefyController;

    address constant vault = 0xF26C10811D602e39580C9448944ddAe7b183fD95;

    function setUp() public {
        setupControllerFacade();
        beefyController = new BeefyController();
        controllerFacade.updateController(vault, beefyController);
    }

    function testCanDeposit() public {
        // Setup
        bytes memory data = abi.encodeWithSelector(0xb6b55f25,
            1e18
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(vault, false, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], vault);
        assertEq(tokensOut[0], IVault(vault).want());
    }

    function testCanDepositAll() public {
        // Setup
        bytes memory data = abi.encodeWithSelector(0xde5f6268);

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(vault, false, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], vault);
        assertEq(tokensOut[0], IVault(vault).want());
    }

    function testCanWithdraw() public {
        // Setup
        bytes memory data = abi.encodeWithSelector(0x2e1a7d4d,
            1e18
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(vault, false, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], IVault(vault).want());
        assertEq(tokensOut[0], vault);
    }

    function testCanWithdrawAll() public {
        // Setup
        bytes memory data = abi.encodeWithSelector(0x853828b6);

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(vault, false, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], IVault(vault).want());
        assertEq(tokensOut[0], vault);
    }

    function testActionRestricted() public {
        // Setup
        bytes memory data = abi.encodeWithSelector(0x853828b7);

        // Test
        (bool canCall,,)
            = controllerFacade.canCall(vault, false, data);

        // Assert
        assertTrue(!canCall);
    }
}