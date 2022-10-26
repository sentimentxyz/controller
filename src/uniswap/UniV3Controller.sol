// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ISwapRouterV3} from "./ISwapRouterV3.sol";
import {IController} from "../core/IController.sol";
import {BytesLib} from "solidity-bytes-utils/BytesLib.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";

/**
    @title Uniswap V3 Controller
    @notice Controller for uniswap v3 interaction
    arbi:0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45
*/
contract UniV3Controller is IController {
    using BytesLib for bytes;

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice size of address stored in bytes
    uint256 private constant ADDR_SIZE = 20;

    /// @notice multicall(bytes[]) function signature
    bytes4 constant MULTICALL = 0xac9650d8;

    /// @notice refundETH()	function signature
    bytes4 constant REFUND_ETH = 0x12210e8a;

    /// @notice unwrapWETH9(uint256,address) function signature
    bytes4 constant UNWRAP_ETH = 0x49404b7c;

    /// @notice exactInputSingle((address,address,uint24,address,uint256,uint256,uint160)) function signature
    bytes4 constant EXACT_INPUT_SINGLE = 0x04e45aaf;

    /// @notice exactOutputSingle((address,address,uint24,address,uint256,uint256,uint160))	function signature
    bytes4 constant EXACT_OUTPUT_SINGLE = 0x5023b4df;

    /// @notice exactInput((bytes,address,uint256,uint256)) function signature
    bytes4 constant EXACT_INPUT = 0xb858183f;

    /// @notice exactOutput((bytes,address,uint256,uint256)) function signature
    bytes4 constant EXACT_OUTPUT = 0x09b81346;

    /* -------------------------------------------------------------------------- */
    /*                               STATE_VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice IControllerFacade
    IControllerFacade public immutable controllerFacade;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _controllerFacade Controller Facade
    */
    constructor(IControllerFacade _controllerFacade) {
        controllerFacade = _controllerFacade;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address, bool useEth, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data); // Slice function selector

        if (sig == MULTICALL) return parseMultiCall(data[4:], useEth);
        if (sig == EXACT_OUTPUT_SINGLE)
            return parseExactOutputSingle(data[4:]);
        if (sig == EXACT_INPUT_SINGLE)
            return parseExactInputSingle(data[4:], useEth);
        if (sig == EXACT_OUTPUT)
            return parseExactOutput(data[4:]);
        if (sig == EXACT_INPUT)
            return parseExactInput(data[4:], useEth);
        return (false, new address[](0), new address[](0));
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Evaluates whether Multi Call can be performed
        @param data calldata for performing multi call
        @return canCall Specifies if the interaction is accepted
        @return tokensIn List of tokens that the account will receive after the
        interactions
        @return tokensOut List of tokens that will be removed from the account
        after the interaction
    */
    function parseMultiCall(bytes calldata data, bool useEth)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        // Decompose function calls
        bytes[] memory calls = abi.decode(data, (bytes[]));

        // Multicalls with > 2 calls are treated as malformed data
        if (calls.length > 2)
            return (false, new address[](0), new address[](0));

        bytes4 sig = bytes4(calls[0]);

        // Handle case when first function call is exactOutputSingle
        if (sig == EXACT_OUTPUT_SINGLE)
            return parseExactOutputSingleMulticall(calls, useEth);

        // Handle case when first function call is exactInputSingle
        if (sig == EXACT_INPUT_SINGLE)
            return parseExactInputSingleMulticall(calls);

        // Handle case when first function call is exactInput
        if (sig == EXACT_INPUT)
            return parseExactInputMulticall(calls);

        // Handle case when first function call is exactOutput
        if (sig == EXACT_OUTPUT)
            return parseExactOutputMulticall(calls, useEth);

        return (false, new address[](0), new address[](0));
    }

    function parseExactOutputSingle(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        // Decode Params
        ISwapRouterV3.ExactOutputSingleParams memory params = abi.decode(
            data,
            (ISwapRouterV3.ExactOutputSingleParams)
        );

        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](1);

        tokensIn[0] = params.tokenOut;
        tokensOut[0] = params.tokenIn;

        return (
            controllerFacade.isTokenAllowed(tokensIn[0]),
            tokensIn,
            tokensOut
        );
    }

    function parseExactOutput(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        // Decode Params
        ISwapRouterV3.ExactOutputParams memory params = abi.decode(
            data,
            (ISwapRouterV3.ExactOutputParams)
        );

        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](1);

        tokensOut[0] = params.path.toAddress(params.path.length - ADDR_SIZE);
        tokensIn[0] = params.path.toAddress(0);

        return (
            controllerFacade.isTokenAllowed(tokensIn[0]),
            tokensIn,
            tokensOut
        );
    }

    function parseExactInputSingle(bytes calldata data, bool useEth)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        // Decode swap params
        ISwapRouterV3.ExactInputSingleParams memory params = abi.decode(
            data,
            (ISwapRouterV3.ExactInputSingleParams)
        );

        address[] memory tokensIn = new address[](1);
        tokensIn[0] = params.tokenOut;

        // If swapping ETH <-> ERC20
        if (useEth) {
            return (
                controllerFacade.isTokenAllowed(tokensIn[0]),
                tokensIn,
                new address[](0)
            );
        }

        address[] memory tokensOut = new address[](1);
        tokensOut[0] = params.tokenIn;

        return (
            controllerFacade.isTokenAllowed(tokensIn[0]),
            tokensIn,
            tokensOut
        );
    }

    function parseExactInput(bytes calldata data, bool useEth)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        // Decode swap params
        ISwapRouterV3.ExactInputParams memory params = abi.decode(
            data,
            (ISwapRouterV3.ExactInputParams)
        );

        address[] memory tokensIn = new address[](1);
        tokensIn[0] = params.path.toAddress(params.path.length - ADDR_SIZE);

        // If swapping ETH <-> ERC20
        if (useEth) {
            return (
                controllerFacade.isTokenAllowed(tokensIn[0]),
                tokensIn,
                new address[](0)
            );
        }

        address[] memory tokensOut = new address[](1);
        tokensOut[0] = params.path.toAddress(0);

        return (
            controllerFacade.isTokenAllowed(tokensIn[0]),
            tokensIn,
            tokensOut
        );
    }

    function parseExactOutputSingleMulticall(
        bytes[] memory multiData,
        bool useEth
    )
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        // remove sig from data and decode params
        ISwapRouterV3.ExactOutputSingleParams memory params = abi.decode(
            multiData[0].slice(4, multiData[0].length - 4),
            (ISwapRouterV3.ExactOutputSingleParams)
        );

        // Swapping Eth <-> ERC20
        if (useEth && bytes4(multiData[1]) == REFUND_ETH) {
            address[] memory tokensIn = new address[](1);
            tokensIn[0] = params.tokenOut;
            return (
                controllerFacade.isTokenAllowed(tokensIn[0]),
                tokensIn,
                new address[](0)
            );
        }

        // Swapping ERC20 <-> ETH
        if (bytes4(multiData[1]) == UNWRAP_ETH) {
            address[] memory tokensOut = new address[](1);
            tokensOut[0] = params.tokenIn;
            return (true, new address[](0), tokensOut);
        }

        return (false, new address[](0), new address[](0));
    }

    function parseExactOutputMulticall(
        bytes[] memory multiData,
        bool useEth
    )
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        // remove sig from data and decode params
        ISwapRouterV3.ExactOutputParams memory params = abi.decode(
            multiData[0].slice(4, multiData[0].length - 4),
            (ISwapRouterV3.ExactOutputParams)
        );

        // Swapping Eth <-> ERC20
        if (useEth && bytes4(multiData[1]) == REFUND_ETH) {
            address[] memory tokensIn = new address[](1);
            tokensIn[0] = params.path.toAddress(0);
            return (
                controllerFacade.isTokenAllowed(tokensIn[0]),
                tokensIn,
                new address[](0)
            );
        }

        // Swapping ERC20 <-> ETH
        if (bytes4(multiData[1]) == UNWRAP_ETH) {
            address[] memory tokensOut = new address[](1);
            tokensOut[0] = params.path.toAddress(params.path.length - ADDR_SIZE);
            return (true, new address[](0), tokensOut);
        }

        return (false, new address[](0), new address[](0));
    }

    function parseExactInputSingleMulticall(
        bytes[] memory multiData
    )
        internal
        pure
        returns (bool, address[] memory, address[] memory)
    {
        // Swap ERC20 <-> ETH
        if (bytes4(multiData[1]) == UNWRAP_ETH) {
            ISwapRouterV3.ExactInputSingleParams memory params = abi.decode(
                multiData[0].slice(4, multiData[0].length - 4),
                (ISwapRouterV3.ExactInputSingleParams)
            );

            address[] memory tokensOut = new address[](1);
            tokensOut[0] = params.tokenIn;
            return (true, new address[](0), tokensOut);
        }
        return (false, new address[](0), new address[](0));
    }

    function parseExactInputMulticall(
        bytes[] memory multiData
    )
        internal
        pure
        returns (bool, address[] memory, address[] memory)
    {
        // Swap ERC20 <-> ETH
        if (bytes4(multiData[1]) == UNWRAP_ETH) {
            ISwapRouterV3.ExactInputParams memory params = abi.decode(
                multiData[0].slice(4, multiData[0].length - 4),
                (ISwapRouterV3.ExactInputParams)
            );

            address[] memory tokensOut = new address[](1);
            tokensOut[0] = params.path.toAddress(0);
            return (true, new address[](0), tokensOut);
        }
        return (false, new address[](0), new address[](0));
    }
}