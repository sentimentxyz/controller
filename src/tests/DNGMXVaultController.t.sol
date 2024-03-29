// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {TestBase} from "./utils/Base.t.sol";
import {DepositPeripheryController} from "../rage/DepositPeripheryController.sol";
import {WithdrawPeripheryController} from "../rage/WithdrawPeripheryController.sol";

interface DNGMXVault {
    function withdrawToken(address token, address receiver, uint256 sGlpAmount) external returns (uint256 amountOut);

    function redeemToken(address token, address receiver, uint256 sharesAmount) external returns (uint256 amountOut);

    function depositToken(address token, address receiver, uint256 tokenAmount)
        external
        returns (uint256 sharesReceived);

    function deposit(address token, address receiver, uint256 tokenAmount) external returns (uint256 sharesReceived);
}

contract TestDNGMXVaultController is TestBase {
    DepositPeripheryController depositController;
    WithdrawPeripheryController withdrawController;

    address depositPeriphery = makeAddr("depositPeriphery");
    address withdrawPeriphery = makeAddr("withdrawPeriphery");
    address vault = makeAddr("vault");

    function setUp() public override {
        super.setUp();
        depositController = new DepositPeripheryController(vault);
        withdrawController = new WithdrawPeripheryController(vault);
        controllerFacade.updateController(depositPeriphery, depositController);
        controllerFacade.updateController(
            withdrawPeriphery,
            withdrawController
        );
    }

    function testDeposit(
        address token,
        address receiver,
        uint64 amt
    ) public {
        // Setup
        controllerFacade.toggleTokenAllowance(vault);

        bytes memory data = abi.encodeWithSelector(DNGMXVault.depositToken.selector, token, receiver, amt);

        // Test
        (
            bool canCall,
            address[] memory tokensIn,
            address[] memory tokensOut
        ) = controllerFacade.canCall(depositPeriphery, false, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], vault);
        assertEq(tokensOut[0], token);
    }

    function testCannotWithdraw(
        address token,
        address receiver,
        uint64 amt
    ) public {
        // Setup
        bytes memory data = abi.encodeWithSelector(DNGMXVault.withdrawToken.selector, token, receiver, amt);

        // Test
        (bool canCall, , ) = controllerFacade.canCall(
            withdrawPeriphery,
            false,
            data
        );

        // Assert
        assertTrue(!canCall);
    }

    function testWithdraw(
        address token,
        address receiver,
        uint64 amt
    ) public {
        // Setup
        controllerFacade.toggleTokenAllowance(token);

        bytes memory data = abi.encodeWithSelector(DNGMXVault.withdrawToken.selector, token, receiver, amt);

        // Test
        (
            bool canCall,
            address[] memory tokensIn,
            address[] memory tokensOut
        ) = controllerFacade.canCall(withdrawPeriphery, false, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], token);
        assertEq(tokensOut[0], vault);
    }

    function testRedeem(
        address token,
        address receiver,
        uint64 amt
    ) public {
        // Setup
        controllerFacade.toggleTokenAllowance(token);

        bytes memory data = abi.encodeWithSelector(DNGMXVault.redeemToken.selector, token, receiver, amt);

        // Test
        (
            bool canCall,
            address[] memory tokensIn,
            address[] memory tokensOut
        ) = controllerFacade.canCall(withdrawPeriphery, false, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], token);
        assertEq(tokensOut[0], vault);
    }

    function testCannotRedeem(
        address token,
        address receiver,
        uint64 amt
    ) public {
        bytes memory data = abi.encodeWithSelector(
            DNGMXVault.redeemToken.selector,
            token,
            receiver,
            amt
        );

        // Test
        (bool canCall, , ) = controllerFacade.canCall(
            withdrawPeriphery,
            false,
            data
        );

        // Assert
        assertTrue(!canCall);
    }

    function testCanNotCallDeposit(
        address token,
        address receiver,
        uint64 amt
    ) public {
        // Setup
        controllerFacade.toggleTokenAllowance(token);

        bytes memory data = abi.encodeWithSelector(
            DNGMXVault.depositToken.selector,
            token,
            receiver,
            amt
        );

        // Test
        (bool canCall, , ) = controllerFacade.canCall(
            withdrawPeriphery,
            false,
            data
        );

        // Assert
        assertTrue(!canCall);
    }

    function testCanNotCallWithdraw(
        address token,
        address receiver,
        uint64 amt
    ) public {
        // Setup
        controllerFacade.toggleTokenAllowance(token);

        bytes memory data = abi.encodeWithSelector(
            DNGMXVault.withdrawToken.selector,
            token,
            receiver,
            amt
        );

        // Test
        (bool canCall, , ) = controllerFacade.canCall(
            depositPeriphery,
            false,
            data
        );

        // Assert
        assertTrue(!canCall);
    }
}
