// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {ICToken} from "./ICToken.sol";
import {IController} from "../core/IController.sol";

contract CompoundController is IController {
    bytes4 constant MINT_ETH = 0x1249c58b;
    bytes4 constant MINT_ERC20 = 0xa0712d68;
    bytes4 constant REDEEM = 0xdb006a75;
    function canCall(address target, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);
        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](1);
        if(sig == MINT_ETH) {
            tokensIn[0] = target;
            return(true, tokensIn, new address[](0));
        }
        if(sig == MINT_ERC20) {
            tokensIn[0] = target;
            tokensOut[0] = ICToken(target).underlying();
            return(true, tokensIn, tokensOut);
        }
        if(sig == REDEEM) {
            tokensOut[0] = target;
            try ICToken(target).underlying() returns (address tokenIn) {
                tokensIn[0] = tokenIn;
                return(true, tokensIn, tokensOut);
            } catch {
                return(true, new address[](0), tokensOut);
            }
        }
        return (false, new address[](0), new address[](0));
    }
}