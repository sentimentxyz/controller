// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {ISwapRouterV3} from "./ISwapRouterV3.sol";
import {IController} from "../core/IController.sol";
import {BytesLib} from "@byteslib/contracts/BytesLib.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";

contract UniV3Controller is IController {
    using BytesLib for bytes;
    
    bytes4 constant MULTICALL = 0xac9650d8;
    bytes4 constant REFUUND_ETH = 0x12210e8a;
    bytes4 constant UNWRAP_ETH = 0x49404b7c;
    bytes4 constant EXACT_INPUT_SINGLE = 0x04e45aaf;
    bytes4 constant EXACT_OUTPUT_SINGLE = 0x5023b4df;

    IControllerFacade public immutable controllerFacade;

    constructor(IControllerFacade _controllerFacade) {
        controllerFacade = _controllerFacade;
    }

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
        return (false, new address[](0), new address[](0));
    }

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
            controllerFacade.isSwapAllowed(tokensIn[0]),
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
                controllerFacade.isSwapAllowed(tokensIn[0]), 
                tokensIn, 
                new address[](0)
            );
        }
        
        address[] memory tokensOut = new address[](1);
        tokensOut[0] = params.tokenIn;
        
        return (
            controllerFacade.isSwapAllowed(tokensIn[0]),
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
        if (useEth && bytes4(multiData[1]) == REFUUND_ETH) {
            address[] memory tokensIn = new address[](1);
            tokensIn[0] = params.tokenOut;
            return (
                controllerFacade.isSwapAllowed(tokensIn[0]),
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
}