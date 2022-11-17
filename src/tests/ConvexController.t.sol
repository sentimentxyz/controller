// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console2.sol";
import {TestBase} from "./utils/Base.t.sol";
import {ConvexBoosterController} from "../convex/ConvexBoosterController.sol";
import {ConvexRewardPoolController} from "../convex/ConvexRewardPoolController.sol";

interface IBooster {
    function addPool(address _lptoken, address _gauge, address _factory) external returns (bool);
    function poolInfo(uint256) external view returns (address, address, address, bool, address);
}

contract TestConvexControllerArbi is TestBase {

    // Convex
    address constant CVX = 0xb952A807345991BD529FDded05009F5e80Fe8F45;
    address constant BOOSTER = 0xF403C135812408BFbE8713b5A23a04b3D48AAE31;
    address constant DEPLOYER = 0x947B7742C403f20e5FaCcDAc5E092C943E7D0277;
    address constant TRICRYPTO_REWARD_POOL = 0x90927a78ad13C0Ec9ACf546cE0C16248A7E7a86D;

    // Curve
    address constant CRV = 0x11cDb42B0EB46D95f990BeDD4695A6e3fA034978;
    address constant TRICRYPTO_LP = 0x8e0B8c8BB9db49a46697F3a5Bb8A308e744821D2;
    address constant TRICRYPTO_GAUGE = 0x555766f3da968ecBefa690Ffd49A2Ac02f47aa5f;
    address constant CURVE_POOL_FACTORY = 0xabC000d88f23Bb45525E447528DBF656A9D55bf5;

    // Controller
    ConvexBoosterController convexBoosterController;
    ConvexRewardPoolController convexRewardPoolController;

    function setUp() public {
        convexBoosterController = new ConvexBoosterController(BOOSTER);
        convexRewardPoolController = new ConvexRewardPoolController();
    }

    function testDeposit() public {
        bytes memory data = abi.encodeWithSignature("deposit(uint256,uint256)", 3, 0);

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) 
            = convexBoosterController.canCall(BOOSTER, false, data);

        assertTrue(canCall);
        assertEq(tokensIn[0], TRICRYPTO_REWARD_POOL);
        assertEq(tokensOut[0], TRICRYPTO_LP);
    }

    function testWithdraw() public {
        bytes memory data = abi.encodeWithSignature("withdraw(uint256,bool)", 0, false);

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) 
            = convexRewardPoolController.canCall(TRICRYPTO_REWARD_POOL, false, data);

        assertTrue(canCall);
        assertEq(tokensIn[0], TRICRYPTO_LP);
        assertEq(tokensOut[0], TRICRYPTO_REWARD_POOL);
    }

    function testWithdrawAndClaim() public {
        bytes memory data = abi.encodeWithSignature("withdraw(uint256,bool)", 0, true);

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) 
            = convexRewardPoolController.canCall(TRICRYPTO_REWARD_POOL, false, data);
        
        assertTrue(canCall);
        assertEq(tokensIn[0], CRV);
        assertEq(tokensIn[1], CVX);
        assertEq(tokensIn[2], TRICRYPTO_LP);
        assertEq(tokensOut[0], TRICRYPTO_REWARD_POOL);
    }

    function testClaim() public {
        bytes memory data = abi.encodeWithSignature("getReward(address)", address(0));

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) 
            = convexRewardPoolController.canCall(TRICRYPTO_REWARD_POOL, false, data);
        
        assertTrue(canCall);
        assertEq(tokensIn[0], CRV);
        assertEq(tokensIn[1], CVX);
        assertEq(tokensOut.length, 0);
    }
}