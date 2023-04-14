// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console2.sol";
import {TestBase} from "./utils/Base.t.sol";
import {OVInvestmentController} from "../origami/OVInvestmentController.sol";
import {IOrigamiInvestment} from "../origami/IOrigamiInvestment.sol";

contract TestOrigamiInvestmentController is TestBase {

    OVInvestmentController ovInvestmentController;

    address vault = makeAddr("vault");

    function setUp() public override {
        super.setUp();
        ovInvestmentController = new OVInvestmentController();
        controllerFacade.updateController(vault, ovInvestmentController);
    }

    function testInvest(address fromToken) public {
        controllerFacade.toggleTokenAllowance(vault);

        IOrigamiInvestment.InvestQuoteData memory quoteData = IOrigamiInvestment.InvestQuoteData({
            fromToken: fromToken,
            fromTokenAmount: 0,
            maxSlippageBps: 0,
            deadline: 0,
            expectedInvestmentAmount: 0,
            minInvestmentAmount: 0,
            underlyingInvestmentQuoteData: bytes("")
        });

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) = controllerFacade.canCall(
            vault, false, abi.encodeWithSelector(IOrigamiInvestment.investWithToken.selector, quoteData)
        );

        assertTrue(canCall);
        assertEq(tokensOut[0], fromToken);
        assertEq(tokensIn[0], vault);
    }

    function testInvestWithNative() public {
        controllerFacade.toggleTokenAllowance(vault);

        IOrigamiInvestment.InvestQuoteData memory quoteData = IOrigamiInvestment.InvestQuoteData({
            fromToken: address(0),
            fromTokenAmount: 0,
            maxSlippageBps: 0,
            deadline: 0,
            expectedInvestmentAmount: 0,
            minInvestmentAmount: 0,
            underlyingInvestmentQuoteData: bytes("")
        });

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) = controllerFacade.canCall(
            vault, false, abi.encodeWithSelector(IOrigamiInvestment.investWithNative.selector, quoteData)
        );

        assertTrue(canCall);
        assertEq(tokensOut.length, 0);
        assertEq(tokensIn[0], vault);
    }

    function testExit(address toToken) public {
        controllerFacade.toggleTokenAllowance(toToken);

        IOrigamiInvestment.ExitQuoteData memory quoteData = IOrigamiInvestment.ExitQuoteData({
            investmentTokenAmount: 0,
            toToken: toToken,
            maxSlippageBps: 0,
            deadline: 0,
            expectedToTokenAmount: 0,
            minToTokenAmount: 0,
            underlyingInvestmentQuoteData: bytes("")
        });

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) = controllerFacade.canCall(
            vault, false, abi.encodeWithSelector(IOrigamiInvestment.exitToToken.selector, quoteData, address(0))
        );

        assertTrue(canCall);
        assertEq(tokensOut[0], vault);
        assertEq(tokensIn[0], toToken);
    }

    function testExitWithNative() public {
        IOrigamiInvestment.ExitQuoteData memory quoteData = IOrigamiInvestment.ExitQuoteData({
            investmentTokenAmount: 0,
            toToken: address(0),
            maxSlippageBps: 0,
            deadline: 0,
            expectedToTokenAmount: 0,
            minToTokenAmount: 0,
            underlyingInvestmentQuoteData: bytes("")
        });

        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) = controllerFacade.canCall(
            vault, false, abi.encodeWithSelector(IOrigamiInvestment.exitToNative.selector, quoteData, address(0))
        );

        assertTrue(canCall);
        assertEq(tokensOut[0], vault);
        assertEq(tokensIn.length, 0);
    }
}
