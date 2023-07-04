// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {TestBase} from "./utils/Base.t.sol";
import {RewardPoolController} from "../aura/RewardPoolController.sol";
import {IERC4626} from "../erc4626/IERC4626.sol";
import {IRewards} from "../aura/IRewards.sol";

contract TestRewardPoolControllerArbi is TestBase {
    RewardPoolController rewardPoolController;

    address target = 0x49e998899FF11598182918098588E8b90d7f60D3;
    address BAL = 0x040d1EdC9569d4Bab2D15287Dc5A4F10F56a56B8;
    address ARB = 0x912CE59144191C1204E64559FE8253a0e49E6548;
    address AURA = 0x1509706a6c66CA549ff0cB464de88231DDBe213B;

    function setUp() public override {
        super.setUp();
        rewardPoolController = new RewardPoolController();
        controllerFacade.updateController(target, rewardPoolController);
    }

    function testCanDeposit(uint256 assets, address sender) public {
        // Setup
        controllerFacade.toggleTokenAllowance(target);

        bytes memory data = abi.encodeWithSelector(0x6e553f65, assets, sender);

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], target);
        assertEq(tokensOut[0], IERC4626(target).asset());
    }

    function testCanMint(uint256 shares, address sender) public {
        // Setup
        controllerFacade.toggleTokenAllowance(target);

        bytes memory data = abi.encodeWithSelector(0x94bf804d, shares, sender);

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], target);
        assertEq(tokensOut[0], IERC4626(target).asset());
    }

    function testCanRedeem(uint256 shares, address sender) public {
        // Setup
        controllerFacade.toggleTokenAllowance(IERC4626(target).asset());

        bytes memory data = abi.encodeWithSelector(0xba087652, shares, sender, sender);

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn.length, 1);
        assertEq(tokensOut.length, 1);
        assertEq(tokensIn[0], IERC4626(target).asset());
        assertEq(tokensOut[0], target);
    }

    function testCanWithdraw(uint256 assets, address sender) public {
        // Setup
        controllerFacade.toggleTokenAllowance(IERC4626(target).asset());

        bytes memory data = abi.encodeWithSelector(0xb460af94, assets, sender, sender);

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn.length, 1);
        assertEq(tokensOut.length, 1);
        assertEq(tokensIn[0], IERC4626(target).asset());
        assertEq(tokensOut[0], target);
    }

    function testCanGetRewards() public {
        // Setup
        controllerFacade.toggleTokenAllowance(ARB);
        controllerFacade.toggleTokenAllowance(BAL);
        controllerFacade.toggleTokenAllowance(AURA);

        bytes memory data = abi.encodeWithSelector(0x3d18b912);

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut.length, 0);
        assertEq(tokensIn[0], ARB);
        assertEq(tokensIn[1], BAL);
        assertEq(tokensIn[2], AURA);
        assertEq(tokensIn.length, 3);
    }
}
