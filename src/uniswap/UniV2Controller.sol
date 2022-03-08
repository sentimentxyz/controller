// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IController} from "../core/IController.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";

contract UniV2Controller is IController {
    bytes4 constant SWAP_EXACT_TOKENS_FOR_TOKENS = 0x38ed1739;
    bytes4 constant SWAP_TOKENS_FOR_EXACT_TOKENS = 0x8803dbee;
    bytes4 constant SWAP_EXACT_ETH_FOR_TOKENS = 0x7ff36ab5;
    bytes4 constant SWAP_TOKENS_FOR_EXACT_ETH = 0x4a25d94a;
    bytes4 constant SWAP_EXACT_TOKENS_FOR_ETH = 0x18cbafe5;
    bytes4 constant SWAP_ETH_FOR_EXACT_TOKENS = 0xfb3bdb41;

    IControllerFacade public immutable controller;

    constructor(IControllerFacade _controller) {
        controller = _controller;
    }

    function canCall(address, bytes calldata data) 
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](1);
        bytes4 sig = bytes4(data);

        if (sig == SWAP_EXACT_TOKENS_FOR_TOKENS 
            || sig == SWAP_TOKENS_FOR_EXACT_TOKENS) 
        {
            (,, address[] memory path,,) 
                = abi.decode(data, (uint, uint, address[], address, uint));

            tokensIn[0] = path[path.length - 1];
            tokensOut[0] = path[0];
            
            return(
                controller.isSwapAllowed(tokensIn[0]), 
                tokensIn, 
                tokensOut
            );
        }

        if (sig == SWAP_EXACT_ETH_FOR_TOKENS
            || sig == SWAP_ETH_FOR_EXACT_TOKENS) 
        {
            (, address[] memory path,,) 
                = abi.decode(data, (uint, address[], address, uint));
            
            tokensIn[0] = path[path.length - 1];

            return (
                controller.isSwapAllowed(tokensIn[0]), 
                tokensIn, 
                new address[](0)
            );
        }

        if (sig == SWAP_TOKENS_FOR_EXACT_ETH
            || sig == SWAP_EXACT_TOKENS_FOR_ETH) 
        {
            (, address[] memory path,,) 
                = abi.decode(data, (uint, address[], address, uint));
            
            tokensOut[0] = path[0];
            
            return (true, new address[](0), tokensOut);
        }

        return(false, new address[](0), new address[](0));
    }
}