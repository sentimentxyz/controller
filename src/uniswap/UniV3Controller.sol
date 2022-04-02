// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {IController} from "../core/IController.sol";
import {IV3SwapRouter} from "./IV3SwapRouter.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";
import {BytesLib} from "../../lib/solidity-bytes-utils/contracts/BytesLib.sol";

contract UniV3Controller is IController {
    using BytesLib for bytes;
    
    bytes4 constant MULTICALL = 0xac9650d8;
    bytes4 constant EXACTOUTPUTSINGLE = 0xdb3e2198;
    bytes4 constant REFUNDETH = 0x12210e8a;
    bytes4 constant UNWRAPETH = 0x49404b7c;
    bytes4 constant EXACTINPUTSINGLE = 0x414bf389;

    IControllerFacade public immutable controllerFacade;

    constructor(IControllerFacade _controllerFacade) {
        controllerFacade = _controllerFacade;
    }

    function canCall(address, bool useEth, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        // Decode signature
        bytes4 sig = bytes4(data);

        // Handle flow when sig is multicall
        if (sig == MULTICALL) {
            
            // Decode multiple function calls
            bytes[] memory multiData = abi.decode(
                data[4:],
                (bytes[])
            );
            
            // Return False if more than two functions are called
            if (multiData.length > 2) 
                return (false, new address[](0), new address[](0));

            // Handle case when first function call is exactOutputSingle
            if (bytes4(multiData[0]) == EXACTOUTPUTSINGLE)
                return canCallExactOutputSingle(multiData, useEth, multiData[0]);

            // Handle case when first function call is exactInputSingle
            if (bytes4(multiData[0]) == EXACTINPUTSINGLE)
                return canCallMultiExactInputSingle(multiData, multiData[0]);
        }

        // Handle flow when sig is exactInputSingle
        if (sig == EXACTINPUTSINGLE) {

            // Decode params
            IV3SwapRouter.ExactOutputSingleParams memory params = abi.decode(
                data[4:],
                (IV3SwapRouter.ExactOutputSingleParams)
            );
            
            address[] memory tokensIn = new address[](1);
            tokensIn[0] = params.tokenOut;
            
            // If swapping Eth <-> ERC20
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
        return (false, new address[](0), new address[](0));
    }

    function canCallExactOutputSingle(
        bytes[] memory multiData,
        bool useEth,
        bytes memory data
    ) 
        internal 
        view 
        returns (bool, address[] memory, address[] memory) 
    {
        // remove sig from data and decode params
        IV3SwapRouter.ExactOutputSingleParams memory params = abi.decode(
            data.slice(4, data.length - 4),
            (IV3SwapRouter.ExactOutputSingleParams)
        );
        
        // Swapping Eth <-> ERC20
        if (useEth && bytes4(multiData[1]) == REFUNDETH) {
            address[] memory tokensIn = new address[](1);
            tokensIn[0] = params.tokenOut;
            return (
                controllerFacade.isSwapAllowed(tokensIn[0]),
                tokensIn,
                new address[](0)
            );
        }

        // Swapping ERC20 <-> ETH   
        if (bytes4(multiData[1]) == UNWRAPETH) {
            address[] memory tokensOut = new address[](1);
            tokensOut[0] = params.tokenIn;
            return (true, new address[](0), tokensOut);
        }
        
        // Swapping ERC20 <-> ERC20
        if (multiData.length == 1) {
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

        return (false, new address[](0), new address[](0));
    }

    function canCallMultiExactInputSingle(
        bytes[] memory multiData,
        bytes memory data
    ) 
        internal 
        pure
        returns (bool, address[] memory, address[] memory) 
    {   
        // Swap ERC20 <-> ETH
        if (bytes4(multiData[1]) == UNWRAPETH) {
            IV3SwapRouter.ExactInputSingleParams memory params = abi.decode(
                data.slice(4, data.length - 4),
                (IV3SwapRouter.ExactInputSingleParams)
            );
            
            address[] memory tokensOut = new address[](1);
            tokensOut[0] = params.tokenIn;
            return (true, new address[](0), tokensOut);
        }
        return (false, new address[](0), new address[](0));
    }
}