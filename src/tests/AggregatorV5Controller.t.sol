// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AggregatorV5Controller} from "../1inch/AggregatorV5Controller.sol";
import {TestBase} from "./utils/Base.t.sol";

interface AggregatorV5 {
    struct SwapDescription {
        address srcToken;
        address dstToken;
        address payable srcReceiver;
        address payable dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
    }

    function swap(address executor, SwapDescription calldata desc, bytes calldata permit, bytes calldata data)
        external
        payable
        returns (uint256 returnAmount, uint256 spentAmount);

    function uniswapV3Swap(uint256 amount, uint256 minReturn, uint256[] calldata pools)
        external
        payable
        returns (uint256 returnAmount);

    function clipperSwap(
        address clipperExchange,
        address srcToken,
        address dstToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 goodUntil,
        bytes32 r,
        bytes32 vs
    ) external payable returns (uint256 returnAmount);
}

contract TestAggregatorV5ControllerArbi is TestBase {
    AggregatorV5Controller aggregatorV5Controller;

    address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address router = 0x1111111254EEB25477B68fb85Ed929f73A960582;

    function setUp() public override {
        super.setUp();
        aggregatorV5Controller = new AggregatorV5Controller();
        controllerFacade.updateController(router, aggregatorV5Controller);
    }

    function testCanCallSwap(address srcToken, address dstToken) public {
        controllerFacade.toggleTokenAllowance(dstToken);
        bytes memory data = abi.encodeWithSelector(
            AggregatorV5.swap.selector,
            address(0),
            AggregatorV5.SwapDescription({
                srcToken: srcToken,
                dstToken: dstToken,
                srcReceiver: payable(address(0)),
                dstReceiver: payable(address(0)),
                amount: 0,
                minReturnAmount: 0,
                flags: 0
            }),
            new bytes(0),
            new bytes(0)
        );

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(router, false, data);
        assertTrue(canCall);
        if (srcToken == ETH) {
            assertEq(tokensOut.length, 0);
        } else {
            assertEq(tokensOut.length, 1);
            assertEq(tokensOut[0], srcToken);
        }

        if (dstToken == ETH) {
            assertEq(tokensIn.length, 0);
        } else {
            assertEq(tokensIn.length, 1);
            assertEq(tokensIn[0], dstToken);
        }
    }

    function testCanCallUniswapV3GMXETH() public {
        uint256[] memory pools = new uint256[](1);
        pools[0] = 72370055773322622139731865631458763244372361429674855427198582849756181302705;
        bytes memory data = abi.encodeWithSelector(AggregatorV5.uniswapV3Swap.selector, uint256(0), uint256(0), pools);

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(router, false, data);
        assertTrue(canCall);
        assertEq(tokensIn.length, 0);
        assertEq(tokensOut.length, 1);
        assertEq(tokensOut[0], 0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a);
    }

    function testCanCallUniswapV3ETHERC20() public {
        controllerFacade.toggleTokenAllowance(0x09E18590E8f76b6Cf471b3cd75fE1A1a9D2B2c2b);
        uint256[] memory pools = new uint256[](1);
        pools[0] = 86844066927987146567678238756644811193063731954949112416874490189640725206927;
        bytes memory data = abi.encodeWithSelector(AggregatorV5.uniswapV3Swap.selector, uint256(0), uint256(0), pools);

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(router, true, data);
        assertTrue(canCall);
        assertEq(tokensOut.length, 0);
        assertEq(tokensIn.length, 1);
        assertEq(tokensIn[0], 0x09E18590E8f76b6Cf471b3cd75fE1A1a9D2B2c2b);
    }

    function testCanCallUniswapV3ERC20ERC20() public {
        controllerFacade.toggleTokenAllowance(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
        uint256[] memory pools = new uint256[](1);
        pools[0] = 270430664898118382726954683614085838321806027164;
        bytes memory data = abi.encodeWithSelector(AggregatorV5.uniswapV3Swap.selector, uint256(0), uint256(0), pools);

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(router, false, data);
        assertTrue(canCall);
        assertEq(tokensOut.length, 1);
        assertEq(tokensOut[0], 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f);
        assertEq(tokensIn.length, 1);
        assertEq(tokensIn[0], 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    }

    function testCanCallClipperSwap(address srcToken, address dstToken) public {
        controllerFacade.toggleTokenAllowance(dstToken);
        bytes memory data = abi.encodeWithSelector(
            AggregatorV5.clipperSwap.selector,
            address(0),
            srcToken,
            dstToken,
            uint256(0),
            uint256(0),
            uint256(0),
            bytes32(0),
            bytes32(0)
        );

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) = aggregatorV5Controller.canCall(address(0), false, data);
        assertTrue(canCall);
        assertEq(tokensIn.length, 1);
        assertEq(tokensIn[0], dstToken);
        assertEq(tokensOut.length, 1);
        assertEq(tokensOut[0], srcToken);
    }
}
