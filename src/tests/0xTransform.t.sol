// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {TestBase} from "./utils/Base.t.sol";
import {ITransformERC20Feature} from "../0x/ITransform.sol";
import {TransformController} from "../0x/TransformController.sol";

contract TestTransformController is TestBase {
    TransformController transformController;

    address target = makeAddr("target");

    address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function setUp() public override {
        super.setUp();
        transformController = new TransformController();
        controllerFacade.updateController(target, transformController);
    }

    function testCanTranformERC20(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut) public {
        vm.assume(tokenIn != ETH && tokenOut != ETH);
        // Setup
        controllerFacade.toggleTokenAllowance(tokenIn);

        ITransformERC20Feature.Transformation[] memory transformations = new ITransformERC20Feature.Transformation[](1);

        bytes memory data = abi.encodeWithSelector(
            ITransformERC20Feature.transformERC20.selector, tokenOut, tokenIn, amountIn, amountOut, transformations
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        if (tokenIn != ETH) {
            assertEq(tokensIn[0], tokenIn);
        } else {
            assertEq(tokensIn.length, 0);
        }
        if (tokenOut != ETH) {
            assertEq(tokensOut[0], tokenOut);
        } else {
            assertEq(tokensOut.length, 0);
        }
    }

    function testCanTranformETHtoERC20(address tokenIn, uint256 amountIn, uint256 amountOut) public {
        vm.assume(tokenIn != ETH);
        // Setup
        controllerFacade.toggleTokenAllowance(tokenIn);

        ITransformERC20Feature.Transformation[] memory transformations = new ITransformERC20Feature.Transformation[](1);

        bytes memory data = abi.encodeWithSelector(
            ITransformERC20Feature.transformERC20.selector, ETH, tokenIn, amountIn, amountOut, transformations
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], tokenIn);
        assertEq(tokensOut.length, 0);
    }

    function testCanTranformERC20ToETH(address tokenOut, uint256 amountIn, uint256 amountOut) public {
        vm.assume(tokenOut != ETH);
        ITransformERC20Feature.Transformation[] memory transformations = new ITransformERC20Feature.Transformation[](1);

        bytes memory data = abi.encodeWithSelector(
            ITransformERC20Feature.transformERC20.selector, tokenOut, ETH, amountIn, amountOut, transformations
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(target, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut[0], tokenOut);
        assertEq(tokensIn.length, 0);
    }
}
