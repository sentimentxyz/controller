// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IController} from "../core/IController.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";
import {IUniV2Factory} from "./IUniV2Factory.sol";

contract UniV2Controller is IController {
    // Swap Functions
    bytes4 constant SWAP_EXACT_TOKENS_FOR_TOKENS = 0x38ed1739;
    bytes4 constant SWAP_TOKENS_FOR_EXACT_TOKENS = 0x8803dbee;
    bytes4 constant SWAP_EXACT_ETH_FOR_TOKENS = 0x7ff36ab5;
    bytes4 constant SWAP_TOKENS_FOR_EXACT_ETH = 0x4a25d94a;
    bytes4 constant SWAP_EXACT_TOKENS_FOR_ETH = 0x18cbafe5;
    bytes4 constant SWAP_ETH_FOR_EXACT_TOKENS = 0xfb3bdb41;

    // LP Functions
    bytes4 constant ADD_LIQUIDITY = 0xe8e33700;
    bytes4 constant REMOVE_LIQUIDITY = 0xbaa2abde;
    bytes4 constant ADD_LIQUIDITY_ETH = 0xf305d719;
    bytes4 constant REMOVE_LIQUIDITY_ETH = 0x02751cec;

    // Constants
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IUniV2Factory constant UNIV2_FACTORY = 
        IUniV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    IControllerFacade public immutable controller;

    constructor(IControllerFacade _controller) {
        controller = _controller;
    }

    function canCall(address, bool, bytes calldata data) 
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        // Swap Functions
        if (sig == SWAP_EXACT_TOKENS_FOR_TOKENS || sig == SWAP_TOKENS_FOR_EXACT_TOKENS)
            return swapErc20ForErc20(data[4:]); // ERC20 -> ERC20
        if (sig == SWAP_EXACT_ETH_FOR_TOKENS || sig == SWAP_ETH_FOR_EXACT_TOKENS)
            return swapEthForErc20(data[4:]); // ETH -> ERC20
        if (sig == SWAP_TOKENS_FOR_EXACT_ETH || sig == SWAP_EXACT_TOKENS_FOR_ETH)
            return swapErc20ForEth(data[4:]); // ERC20 -> ETH
        
        // LP Functions
        if (sig == ADD_LIQUIDITY) return addLiquidity(data[4:]);
        if (sig == REMOVE_LIQUIDITY) return removeLiquidity(data[4:]);
        if (sig == ADD_LIQUIDITY_ETH) return addLiquidityEth(data[4:]);
        if (sig == REMOVE_LIQUIDITY_ETH) return removeLiquidityEth(data[4:]);

        return(false, new address[](0), new address[](0));
    }

    function addLiquidity(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (address tokenA, address tokenB) = abi.decode(data, (address, address));

        address[] memory tokensOut = new address[](2);
        tokensOut[0] = tokenA;
        tokensOut[1] = tokenB;

        address[] memory tokensIn = new address[](1);
        tokensIn[0] = UNIV2_FACTORY.getPair(tokenA, tokenB);

        return(controller.isTokenAllowed(tokensIn[0]), tokensIn, tokensOut);
    }

    function addLiquidityEth(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        address token = abi.decode(data, (address));
        
        address[] memory tokensOut = new address[](1);
        tokensOut[0] = token;

        address[] memory tokensIn = new address[](1);
        tokensIn[0] = UNIV2_FACTORY.getPair(token, WETH);

        return(controller.isTokenAllowed(tokensIn[0]), tokensIn, tokensOut);
    }

    function removeLiquidity(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (address tokenA, address tokenB) = abi.decode(data, (address, address));

        address[] memory tokensIn = new address[](2);
        tokensIn[0] = tokenA;
        tokensIn[1] = tokenB;

        address[] memory tokensOut = new address[](1);
        tokensOut[0] = UNIV2_FACTORY.getPair(tokenA, tokenB);

        return(true, tokensIn, tokensOut);
    }

    function removeLiquidityEth(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (address token) = abi.decode(data, (address));

        address[] memory tokensIn = new address[](1);
        tokensIn[0] = token;

        address[] memory tokensOut = new address[](1);
        tokensOut[0] = UNIV2_FACTORY.getPair(token, WETH);

        return(true, tokensIn, tokensOut);
    }

    function swapErc20ForErc20(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (,, address[] memory path,,) 
                = abi.decode(data, (uint, uint, address[], address, uint));
        
        address[] memory tokensOut = new address[](1);
        tokensOut[0] = path[0];

        address[] memory tokensIn = new address[](1);
        tokensIn[0] = path[path.length - 1];
            
        return(
            controller.isTokenAllowed(tokensIn[0]), 
            tokensIn, 
            tokensOut
        );
    }

    function swapEthForErc20(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (, address[] memory path,,) 
                = abi.decode(data, (uint, address[], address, uint));

        address[] memory tokensIn = new address[](1);       
        tokensIn[0] = path[path.length - 1];

        return (
            controller.isTokenAllowed(tokensIn[0]), 
            tokensIn, 
            new address[](0)
        );
    }

    function swapErc20ForEth(bytes calldata data)
        internal
        pure
        returns (bool, address[] memory, address[] memory)
    {
        (, address[] memory path,,) 
                = abi.decode(data, (uint, address[], address, uint));
        
        address[] memory tokensOut = new address[](1);
        tokensOut[0] = path[0];
            
        return (true, new address[](0), tokensOut);
    }
}