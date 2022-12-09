// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {TestBase} from "./utils/Base.t.sol";
import {IVault, IAsset} from "../balancer/IVault.sol";
import {BalancerController} from "../balancer/BalancerController.sol";

contract TestBalancer is TestBase {

    BalancerController balancerController;

    address constant vault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    function setUp() override public {
        super.setUp();
        balancerController = new BalancerController();
        controllerFacade.updateController(vault, balancerController);
    }

    function testCanJoin() public {
        // Setup
        controllerFacade.toggleTokenAllowance(0xCfCA23cA9CA720B6E98E3Eb9B6aa0fFC4a5C08B9);

        bytes32 poolId = 0xcfca23ca9ca720b6e98e3eb9b6aa0ffc4a5c08b9000200000000000000000274;
        address sender = 0xABBb9Eb2512904123f9d372f26e2390a190d8550;
        address receiver = 0xABBb9Eb2512904123f9d372f26e2390a190d8550;

        IAsset[] memory assets = new IAsset[](2);
        assets[0] = IAsset(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        assets[1] = IAsset(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);

        uint256[] memory maxAmountsIn = new uint256[](2);
        maxAmountsIn[0] = 0;
        maxAmountsIn[1] = 5283061898487873009179;

        bytes memory userData = "000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000013d76dd2f55e7a75f0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000141f6f514c5100000";

        bool internalBalance = false;

        IVault.JoinPoolRequest memory request = IVault.JoinPoolRequest(
            assets,
            maxAmountsIn,
            userData,
            internalBalance
        );

        bytes memory data = abi.encodeWithSelector(0xb95cac28,
            poolId,
            sender,
            receiver,
            request
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(vault, true, data);

        (address token,) = IVault(vault).getPool(poolId);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], token);
        assertEq(tokensOut[0], address(assets[1]));
    }

    function testCannotJoin() public {
        // Setup
        bytes32 poolId = 0xcfca23ca9ca720b6e98e3eb9b6aa0ffc4a5c08b9000200000000000000000274;
        address sender = 0xABBb9Eb2512904123f9d372f26e2390a190d8550;
        address receiver = 0xABBb9Eb2512904123f9d372f26e2390a190d8550;

        IAsset[] memory assets = new IAsset[](2);
        assets[0] = IAsset(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        assets[1] = IAsset(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);

        uint256[] memory maxAmountsIn = new uint256[](2);
        maxAmountsIn[0] = 0;
        maxAmountsIn[1] = 5283061898487873009179;

        bytes memory userData = "000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000013d76dd2f55e7a75f0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000141f6f514c5100000";

        bool internalBalance = false;

        IVault.JoinPoolRequest memory request = IVault.JoinPoolRequest(
            assets,
            maxAmountsIn,
            userData,
            internalBalance
        );

        bytes memory data = abi.encodeWithSelector(0xb95cac28,
            poolId,
            sender,
            receiver,
            request
        );

        // Test
        (bool canCall,,)
            = controllerFacade.canCall(vault, true, data);

        // Assert
        assertTrue(!canCall);
    }

    function testCanExit() public {
        // Setup
        controllerFacade.toggleTokenAllowance(0xCfCA23cA9CA720B6E98E3Eb9B6aa0fFC4a5C08B9);
        controllerFacade.toggleTokenAllowance(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);
        bytes32 poolId = 0xcfca23ca9ca720b6e98e3eb9b6aa0ffc4a5c08b9000200000000000000000274;
        address sender = 0xABBb9Eb2512904123f9d372f26e2390a190d8550;
        address receiver = 0xABBb9Eb2512904123f9d372f26e2390a190d8550;

        IAsset[] memory assets = new IAsset[](2);
        assets[0] = IAsset(0x0000000000000000000000000000000000000000);
        assets[1] = IAsset(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);

        uint256[] memory maxAmountsIn = new uint256[](3);
        maxAmountsIn[0] = 13432569841622014589;
        maxAmountsIn[1] = 0;

        bytes memory userData = "000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000013d76dd2f55e7a75f0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000141f6f514c5100000";

        bool internalBalance = false;

        IVault.ExitPoolRequest memory request = IVault.ExitPoolRequest(
            assets,
            maxAmountsIn,
            userData,
            internalBalance
        );

        bytes memory data = abi.encodeWithSelector(0x8bdb3913,
            poolId,
            sender,
            receiver,
            request
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(vault, true, data);

        (address token,) = IVault(vault).getPool(poolId);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut[0], token);
        assertEq(tokensIn.length, 1);
    }

    function testCanSwap() public {
        // Setup
        controllerFacade.toggleTokenAllowance(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);

        IVault.SingleSwap memory swap = IVault.SingleSwap(
            "0",
            0,
            IAsset(0xCfCA23cA9CA720B6E98E3Eb9B6aa0fFC4a5C08B9),
            IAsset(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF),
            0,
            "0"
        );

        IVault.FundManagement memory funds = IVault.FundManagement(
            address(0),
            false,
            payable(address(0)),
            false
        );

        bytes memory data = abi.encodeWithSelector(0x52bbbe29,
            swap,
            funds,
            0,
            0
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(vault, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut[0], 0xCfCA23cA9CA720B6E98E3Eb9B6aa0fFC4a5C08B9);
        assertEq(tokensIn[0], 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);
        assertEq(tokensIn.length, 1);
        assertEq(tokensOut.length, 1);
    }

    function testCanBatchSwapGivenIn() public {
        // Setup
        controllerFacade.toggleTokenAllowance(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);

        int256[] memory limits = new int256[](3);

        IAsset[] memory assets = new IAsset[](3);
        assets[0] = IAsset(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
        assets[1] = IAsset(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        assets[2] = IAsset(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);

        IVault.BatchSwapStep memory swap1 = IVault.BatchSwapStep(
            "0",
            0,
            1,
            10,
            "0"
        );

        IVault.BatchSwapStep memory swap2 = IVault.BatchSwapStep(
            "0",
            1,
            2,
            0,
            "0"
        );

        IVault.FundManagement memory funds = IVault.FundManagement(
            address(0),
            false,
            payable(address(0)),
            false
        );

        IVault.BatchSwapStep[] memory swaps = new IVault.BatchSwapStep[](2);
        swaps[0] = swap1;
        swaps[1] = swap2;

        bytes memory data = abi.encodeWithSelector(0x945bcec9,
            IVault.SwapKind.GIVEN_IN,
            swaps,
            assets,
            funds,
            limits,
            0
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(vault, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut[0], 0xBA12222222228d8Ba445958a75a0704d566BF2C8);
        assertEq(tokensIn[0], 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);
        assertEq(tokensIn.length, 1);
        assertEq(tokensOut.length, 1);
    }

    function testCanBatchSwapGivenOut() public {
        // Setup
        controllerFacade.toggleTokenAllowance(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);

        int256[] memory limits = new int256[](3);

        IAsset[] memory assets = new IAsset[](3);
        assets[0] = IAsset(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
        assets[1] = IAsset(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        assets[2] = IAsset(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);

        IVault.BatchSwapStep memory swap1 = IVault.BatchSwapStep(
            "0",
            1,
            2,
            10,
            "0"
        );

        IVault.BatchSwapStep memory swap2 = IVault.BatchSwapStep(
            "0",
            0,
            1,
            0,
            "0"
        );

        IVault.FundManagement memory funds = IVault.FundManagement(
            address(0),
            false,
            payable(address(0)),
            false
        );

        IVault.BatchSwapStep[] memory swaps = new IVault.BatchSwapStep[](2);
        swaps[0] = swap1;
        swaps[1] = swap2;

        bytes memory data = abi.encodeWithSelector(0x945bcec9,
            IVault.SwapKind.GIVEN_OUT,
            swaps,
            assets,
            funds,
            limits,
            0
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(vault, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut[0], 0xBA12222222228d8Ba445958a75a0704d566BF2C8);
        assertEq(tokensIn[0], 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);
        assertEq(tokensIn.length, 1);
        assertEq(tokensOut.length, 1);
    }
}