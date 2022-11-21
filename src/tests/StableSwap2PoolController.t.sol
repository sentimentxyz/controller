// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {TestBase} from "./utils/Base.t.sol";
import {StableSwap2PoolEthController} from "../curve/StableSwap2PoolEthController.sol";
import {IStableSwapPool} from "../curve/IStableSwapPool.sol";

contract TestStableSwap2PoolEthControllerArbi is TestBase {

    StableSwap2PoolEthController curveController;

    address constant pool = 0x6eB2dc694eB516B16Dc9FBc678C60052BbdD7d80;
    address constant lp = 0xDbcD16e622c95AcB2650b38eC799f76BFC557a0b;
    address constant WSTETH = 0x5979D7b546E38E414F7E9822514be443A4800529;

    function setUp() public {
        setupControllerFacade();
        curveController = new StableSwap2PoolEthController(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
        controllerFacade.updateController(pool, curveController);
    }

    function testCanAddLiquidityAllTokens() public {
        // Setup
        controllerFacade.toggleTokenAllowance(lp);

        uint256[2] memory amounts;
        amounts[0] = 123;
        amounts[1] = 123;

        bytes memory data = abi.encodeWithSelector(0x0b4c7e4d,
            amounts,
            123
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(pool, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], lp);
        assertEq(tokensOut[0], WSTETH);
    }

    function testCanAddLiquidityToken() public {
        // Setup
        controllerFacade.toggleTokenAllowance(lp);

        uint256[2] memory amounts;
        amounts[1] = 123;

        bytes memory data = abi.encodeWithSelector(0x0b4c7e4d,
            amounts,
            123
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(pool, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], lp);
        assertEq(tokensOut[0], WSTETH);
        assertEq(tokensOut.length, 1);
    }

    function testCanAddLiquidityETH() public {
        // Setup
        controllerFacade.toggleTokenAllowance(lp);

        uint256[2] memory amounts;
        amounts[0] = 123;

        bytes memory data = abi.encodeWithSelector(0x0b4c7e4d,
            amounts,
            123
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(pool, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn[0], lp);
        assertEq(tokensOut.length, 0);
    }

    function testCanRemoveLiquidityETH() public {

        bytes memory data = abi.encodeWithSelector(0x1a4d01d2,
            123,
            0,
            123
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(pool, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut[0], lp);
        assertEq(tokensIn.length, 0);
    }

    function testCanRemoveLiquidityToken() public {
        // Setup
        controllerFacade.toggleTokenAllowance(WSTETH);

        bytes memory data = abi.encodeWithSelector(0x1a4d01d2,
            123,
            1,
            123
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(pool, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut[0], lp);
        assertEq(tokensIn.length, 1);
        assertEq(tokensIn[0], WSTETH);
    }

    function testCanRemoveLiquidity() public {
        // Setup
        controllerFacade.toggleTokenAllowance(WSTETH);

        uint256[2] memory amounts;
        amounts[0] = 123;
        amounts[1] = 123;

        bytes memory data = abi.encodeWithSelector(0x5b36389c,
            123,
            amounts
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(pool, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut[0], lp);
        assertEq(tokensIn.length, 1);
        assertEq(tokensIn[0], WSTETH);
    }

    function testCanExchangeETHtoWSTETH() public {
        // Setup
        controllerFacade.toggleTokenAllowance(WSTETH);

        bytes memory data = abi.encodeWithSelector(0x3df02124,
            0,
            1,
            1,
            1
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(pool, true, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensOut.length, 0);
        assertEq(tokensIn[0], WSTETH);
    }

    function testCanExchangeWSTETHtoETH() public {
        // Setup
        controllerFacade.toggleTokenAllowance(WSTETH);

        bytes memory data = abi.encodeWithSelector(0x3df02124,
            1,
            0,
            1,
            1
        );

        // Test
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut)
            = controllerFacade.canCall(pool, false, data);

        // Assert
        assertTrue(canCall);
        assertEq(tokensIn.length, 0);
        assertEq(tokensOut[0], WSTETH);
    }
}