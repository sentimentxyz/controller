// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {TestBase} from "./utils/Base.t.sol";
import {PirexGMXController} from "../pirex/PirexGMXController.sol";

interface IPirexGMX {
    function depositGlp(
        address token,
        uint256 tokenAmount,
        uint256 minUsdg,
        uint256 minGlp,
        address receiver
    ) external returns (uint256, uint256, uint256);

    function redeemPxGlp(
        address token,
        uint256 amount,
        uint256 minOut,
        address receiver
    ) external returns (uint256, uint256, uint256);

    function redeemPxGlpETH(
        uint256 amount,
        uint256 minOut,
        address receiver
    ) external returns (uint256, uint256, uint256);

    function depositGlpETH(
        uint256 minUsdg,
        uint256 minGlp,
        address receiver
    ) external returns (uint256, uint256, uint256);

    function depositGmx(uint256 amount, address receiver) external returns (uint256, uint256, uint256);
}

contract TestPirexGMXController is TestBase {

    PirexGMXController vaultController;

    address target = makeAddr("target");
    address PXGMX = makeAddr("PXGMX");
    address PXGLP = makeAddr("PXGLP");
    address GMX = makeAddr("GMX");

    function setUp() public {
        setupControllerFacade();
        vaultController = new PirexGMXController(PXGMX, PXGLP, GMX);
        controllerFacade.updateController(target, vaultController);
    }

    function testDepositGMX(address receiver, uint64 amt) public {
        // Setup
        controllerFacade.toggleTokenAllowance(PXGMX);

        bytes memory data = abi.encodeWithSelector(
            IPirexGMX.depositGmx.selector,
            receiver,
            amt
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(target, false, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], PXGMX);
        assertEq(tokensOut[0], GMX);
    }

    function testDepositGLPETH(address receiver, uint64 amt, uint64 amt2) public {
        // Setup
        controllerFacade.toggleTokenAllowance(PXGLP);

        bytes memory data = abi.encodeWithSelector(
            IPirexGMX.depositGlpETH.selector,
            amt,
            amt2,
            receiver
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], PXGLP);
        assertEq(tokensOut.length, 0);
    }

    function testRedeemPXGLPETH(address receiver, uint64 amt, uint64 amt2) public {
        bytes memory data = abi.encodeWithSelector(
            IPirexGMX.redeemPxGlpETH.selector,
            amt,
            amt2,
            receiver
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(target, false, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut[0], PXGLP);
        assertEq(tokensIn.length, 0);
    }

    function testDepositGLP(address receiver, uint64 amt, uint64 amt2, uint64 amt3, address token) public {
        // Setup
        controllerFacade.toggleTokenAllowance(PXGLP);

        bytes memory data = abi.encodeWithSelector(
            IPirexGMX.depositGlp.selector,
            token,
            amt3,
            amt,
            amt2,
            receiver
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(target, false, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], PXGLP);
        assertEq(tokensOut[0], token);
    }

    function testRedeemPXGLP(address receiver, uint64 amt, uint64 amt2, address token) public {
        // Setup
        controllerFacade.toggleTokenAllowance(token);

        bytes memory data = abi.encodeWithSelector(
            IPirexGMX.redeemPxGlp.selector,
            token,
            amt,
            amt2,
            receiver
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(target, false, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut[0], PXGLP);
        assertEq(tokensIn[0], token);
    }
}