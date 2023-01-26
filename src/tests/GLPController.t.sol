// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console2.sol";
import {TestBase} from "./utils/Base.t.sol";
import {RewardRouterV2Controller} from "../gmx/RewardRouterV2Controller.sol";
import {RewardRouterController} from "../gmx/RewardRouterController.sol";

interface IRewardRouter {
     function mintAndStakeGlp(
        address _token,
        uint256 _amount,
        uint256 _minUsdg,
        uint256 _minGlp
    ) external returns (uint256);

    function mintAndStakeGlpETH(uint256 _minUsdg, uint256 _minGlp) external payable returns (uint256);

    function unstakeAndRedeemGlp(
        address _tokenOut,
        uint256 _glpAmount,
        uint256 _minOut,
        address _receiver
    ) external returns (uint256);

    function unstakeAndRedeemGlpETH(
        uint256 _glpAmount,
        uint256 _minOut,
        address payable _receiver
    ) external returns (uint256);

    function claimFees() external;

    function compound() external;
}

contract TestGLPControllerArbi is TestBase {

    RewardRouterV2Controller rewardRouterV2Controller;
    RewardRouterController rewardRouterController;

    // GMX
    address constant SGLP = 0x5402B5F40310bDED796c7D0F3FF6683f5C0cFfdf;
    address constant rewardRouterV2 = 0xB95DB5B167D75e6d04227CfFFA61069348d271F5;
    address constant rewardRouter = 0xA906F338CB21815cBc4Bc87ace9e68c87eF8d8F1;
    address WETH = makeAddr("WETH");

    function setUp() override public {
        super.setUp();
        rewardRouterV2Controller = new RewardRouterV2Controller(SGLP);
        rewardRouterController = new RewardRouterController(WETH);
        controllerFacade.updateController(rewardRouterV2, rewardRouterV2Controller);
        controllerFacade.updateController(rewardRouter, rewardRouterController);
    }

    function testCanMintAndStake(address token, uint64 amt, uint64 minUSDG, uint64 minGLP) public {
        controllerFacade.toggleTokenAllowance(SGLP);
        bytes memory data = abi.encodeWithSelector(
            IRewardRouter.mintAndStakeGlp.selector,
            token,
            amt,
            minUSDG,
            minGLP
        );

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(rewardRouterV2, false, data);

        assertTrue(canCall);
        assertEq(tokensIn[0], SGLP);
        assertEq(tokensOut[0], token);
    }

    function testCanMintAndStakeEth(uint64 minUSDG, uint64 minGLP) public {
        controllerFacade.toggleTokenAllowance(SGLP);
        bytes memory data = abi.encodeWithSelector(
            IRewardRouter.mintAndStakeGlpETH.selector,
            minUSDG,
            minGLP
        );

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(rewardRouterV2, true, data);

        assertTrue(canCall);
        assertEq(tokensIn[0], SGLP);
        assertEq(tokensOut.length, 0);
    }

    function testCanUnstakeAndRedeemGLPEth(uint256 _glpAmount, uint256 _minOut, address payable _receiver) public {

        bytes memory data = abi.encodeWithSelector(
            IRewardRouter.unstakeAndRedeemGlpETH.selector,
            _glpAmount,
            _minOut,
            _receiver
        );

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(rewardRouterV2, false, data);

        assertTrue(canCall);
        assertEq(tokensOut[0], SGLP);
        assertEq(tokensIn.length, 0);
    }

    function testCanUnstakeAndRedeemGLP(address _token, uint256 _glpAmount, uint256 _minOut, address payable _receiver) public {
        controllerFacade.toggleTokenAllowance(_token);
        bytes memory data = abi.encodeWithSelector(
            IRewardRouter.unstakeAndRedeemGlp.selector,
            _token,
            _glpAmount,
            _minOut,
            _receiver
        );

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(rewardRouterV2, false, data);

        assertTrue(canCall);
        assertEq(tokensOut[0], SGLP);
        assertEq(tokensIn[0], _token);
    }

    function testCanCompound() public {
        controllerFacade.toggleTokenAllowance(WETH);
        bytes memory data = abi.encodeWithSelector(
            IRewardRouter.compound.selector
        );

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(rewardRouter, false, data);

        assertTrue(canCall);
        assertEq(tokensOut.length, 0);
        assertEq(tokensIn[0], WETH);
    }

    function testCanClaimFees() public {
        controllerFacade.toggleTokenAllowance(WETH);

        bytes memory data = abi.encodeWithSelector(
            IRewardRouter.claimFees.selector
        );

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(rewardRouter, false, data);

        assertTrue(canCall);
        assertEq(tokensOut.length, 0);
        assertEq(tokensIn[0], WETH);
    }
}