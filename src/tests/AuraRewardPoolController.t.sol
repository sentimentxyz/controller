// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {TestBase} from "./utils/Base.t.sol";
import {RewardPoolController} from "../aura/RewardPoolController.sol";
import {IERC4626} from "../erc4626/IERC4626.sol";
import {IRewards} from "../aura/IRewards.sol";

contract TestRewardPoolControllerMainnet is TestBase {
    RewardPoolController rewardPoolController;

    address target = 0xe4683Fe8F53da14cA5DAc4251EaDFb3aa614d528;
    address BAL = 0xba100000625a3754423978a60c9317c58a424e3D;
    address LDO = 0x5A98FcBEA516Cf06857215779Fd812CA3beF1B32;
    address AURA = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;

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
        controllerFacade.toggleTokenAllowance(LDO);
        controllerFacade.toggleTokenAllowance(BAL);
        controllerFacade.toggleTokenAllowance(AURA);

        bytes memory data = abi.encodeWithSelector(0x3d18b912);

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut.length, 0);
        assertEq(tokensIn[0], LDO);
        assertEq(tokensIn[1], BAL);
        assertEq(tokensIn[2], AURA);
        assertEq(tokensIn.length, 3);
    }
}
