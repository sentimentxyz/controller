// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IController} from "../core/IController.sol";
import {IStableSwapPool} from "./IStableSwapPool.sol";
import {IControllerFacade} from "../core/IControllerFacade.sol";

contract CurveCryptoSwapController is IController {
    IControllerFacade public immutable controllerFacade;
    bytes4 public constant EXCHANGE = 0x394747c5;
    bytes4 public constant ADD_LIQUIDITY = 0x4515cef3;
    bytes4 public constant REMOVE_LIQUIDITY = 0xecb586a5;
    bytes4 public constant REMOVE_LIQUIDITY_ONE_COIN = 0xf1dc3cc9;

    constructor(IControllerFacade _controllerFacade) {
        controllerFacade = _controllerFacade;
    }

    function canCall(address target, bool useEth, bytes calldata data) 
        external
        view
        returns (bool, address[] memory, address[] memory)  
    {   
        bytes4 sig = bytes4(data);

        if (sig == ADD_LIQUIDITY) return canAddLiquidity(target, data);
        if (sig == REMOVE_LIQUIDITY_ONE_COIN) 
            return canRemoveLiquidityOneCoin(target, data);
        if (sig == REMOVE_LIQUIDITY) return canRemoveLiquidity(target, data);
        if (sig == EXCHANGE) return canExchange(target, useEth, data);
        
        return (false, new address[](0), new address[](0));
    }

    function canAddLiquidity(address target, bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (uint256[3] memory amounts,) = abi.decode(
            data[4:],
            (uint256[3], uint256)
        );
            
        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](3);
            
        tokensIn[0] = IStableSwapPool(target).token();
        for (uint i=0; i<3; i++)
            if (amounts[i] > 0) 
                tokensOut[i] = IStableSwapPool(target).coins(i);
        
        return (true, tokensIn, tokensOut);
    }

    function canRemoveLiquidityOneCoin(address target, bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (,uint256 i, uint256 min_amount) = abi.decode(
            data[4:],
            (uint256, uint256, uint256)
        );
            
        if (min_amount == 0)
            return (false, new address[](0), new address[](0));

        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](1);
        
        tokensIn[0] = IStableSwapPool(target).coins(i);
        tokensOut[0] = IStableSwapPool(target).token();

        return (true, tokensIn, tokensOut);
    }

    function canRemoveLiquidity(address target, bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (,uint256[3] memory amounts) = abi.decode(
            data[4:],
            (uint256, uint256[3])
        );
            
        address[] memory tokensIn = new address[](3);
        address[] memory tokensOut = new address[](1);
            
        for (uint i=0; i < 3; i++)
            if (amounts[i] > 0) 
                tokensIn[i] = IStableSwapPool(target).coins(i);
        
        tokensOut[0] = IStableSwapPool(target).token();
        return (true, tokensIn, tokensOut);
    }

    function canExchange(address target, bool useEth, bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (uint256 i, uint256 j) = abi.decode(
            data[4:],
            (uint256, uint256)
        );

        address[] memory tokensIn = new address[](1);
        tokensIn[0] = IStableSwapPool(target).coins(j);
            
        if (useEth) 
            return (
                controllerFacade.isSwapAllowed(tokensIn[0]),
                tokensIn,
                new address[](0)
            );

        address[] memory tokensOut = new address[](1);
        tokensOut[0] = IStableSwapPool(target).coins(i);
            
        return (
            controllerFacade.isSwapAllowed(tokensIn[0]), 
            tokensIn, 
            tokensOut
        );
    }
}