// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {TestBase} from "./utils/Base.t.sol";
import {BalancerLPStakingController} from "../balancer/BalancerLPStakingController.sol";

contract TestBalancerStakingArbi is TestBase {

    BalancerLPStakingController balancerController;

    address constant gauge = 0x5b6776cD9c51768Fc915caD7a7e8F5c4a6331131;
    address constant lp = 0xFB5e6d0c1DfeD2BA000fBC040Ab8DF3615AC329c;
    address constant r1 = 0x040d1EdC9569d4Bab2D15287Dc5A4F10F56a56B8;
    address constant r2 = 0x13Ad51ed4F1B7e9Dc168d8a00cB3f4dDD85EfA60;

    function setUp() public {
        setupControllerFacade();
        balancerController = new BalancerLPStakingController();
        controllerFacade.updateController(gauge, balancerController);
    }

    function testCanDeposit() public {
        // Setup
        controllerFacade.toggleTokenAllowance(gauge);

        bytes memory data = abi.encodeWithSelector(0xb6b55f25,
            0
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(gauge, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], gauge);
        assertEq(tokensOut[0], lp);
    }

    function testCannotDeposit() public {
        bytes memory data = abi.encodeWithSelector(0xb6b55f25,
            0
        );

        // Test
        (bool canCall,,)
            = controllerFacade.canCall(gauge, true, data);

        // Assert
        assertTrue(!canCall);
    }

    function testCanDepositAndClaim(bool claim) public {
        // Setup
        controllerFacade.toggleTokenAllowance(gauge);
        controllerFacade.toggleTokenAllowance(r1);
        controllerFacade.toggleTokenAllowance(r2);

        bytes memory data = abi.encodeWithSelector(0x83df6747,
            0,
            address(0),
            claim
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(gauge, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut[0], lp);
        if (claim) {
            assertEq(tokensIn[0], r1);
            assertEq(tokensIn[1], r2);
            assertEq(tokensIn[2], gauge);
            assertEq(tokensIn.length, 3);
        } else {
            assertEq(tokensIn[0], gauge);
            assertEq(tokensIn.length, 1);
        }
    }

    function testCannotDepositAndClaim() public {
        bytes memory data = abi.encodeWithSelector(0x83df6747,
            0,
            address(0),
            true
        );

        // Test
        (bool canCall,,)
            = controllerFacade.canCall(gauge, true, data);

        // Assert
        assertTrue(!canCall);
    }

    function testCanWithdrawAndClaim(bool claim) public {
        // Setup
        controllerFacade.toggleTokenAllowance(lp);
        controllerFacade.toggleTokenAllowance(r1);
        controllerFacade.toggleTokenAllowance(r2);

        bytes memory data = abi.encodeWithSelector(0x38d07436,
            0,
            claim
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(gauge, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut[0], gauge);

        if (claim) {
            assertEq(tokensIn[0], r1);
            assertEq(tokensIn[1], r2);
            assertEq(tokensIn[2], lp);
            assertEq(tokensIn.length, 3);
        } else {
            assertEq(tokensIn[0], lp);
            assertEq(tokensIn.length, 1);
        }
    }

    function testCannotWithdrawAndClaim() public {
        bytes memory data = abi.encodeWithSelector(0x38d07436,
            0,
            true
        );

        // Test
        (bool canCall,,)
            = controllerFacade.canCall(gauge, true, data);

        // Assert
        assertTrue(!canCall);
    }

    function testCanWithdraw() public {
        // Setup
        controllerFacade.toggleTokenAllowance(lp);

        bytes memory data = abi.encodeWithSelector(0x2e1a7d4d,
            0
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(gauge, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], lp);
        assertEq(tokensOut[0], gauge);
    }

    function testCannotWithdraw() public {
        bytes memory data = abi.encodeWithSelector(0x2e1a7d4d,
            0
        );

        // Test
        (bool canCall,,)
            = controllerFacade.canCall(gauge, true, data);

        // Assert
        assertTrue(!canCall);
    }

    function testCanClaim() public {
        // Setup
        controllerFacade.toggleTokenAllowance(r1);
        controllerFacade.toggleTokenAllowance(r2);

        bytes memory data = abi.encodeWithSelector(0xe6f1daf2);

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(gauge, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], r1);
        assertEq(tokensIn[1], r2);
        assertEq(tokensIn.length, 2);
        assertEq(tokensOut.length, 0);
    }

    function testCannotClaim() public {
        bytes memory data = abi.encodeWithSelector(0xe6f1daf2);

        // Test
        (bool canCall,,)
            = controllerFacade.canCall(gauge, true, data);

        // Assert
        assertTrue(!canCall);
    }

    function testCannotCall() public {
        bytes memory data = abi.encodeWithSelector(0xe6f1aaf2);

        // Test
        (bool canCall,,)
            = controllerFacade.canCall(gauge, true, data);

        // Assert
        assertTrue(!canCall);
    }
}