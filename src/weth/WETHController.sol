// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IController} from "../core/IController.sol";

contract WETHController is IController {
    bytes4 constant DEPOSIT = 0xd0e30db0;
    bytes4 constant WITHDRAW = 0x2e1a7d4d;
    address[] public weth; // WETH9
    
    constructor(address wEth) {
        weth.push(wEth);
    }

    function canCall(
        address,
        bytes calldata data
    ) external view returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);
        if(sig == DEPOSIT) return (true, weth, new address[](0));
        if(sig == WITHDRAW) return (true, new address[](0), weth);
        return (false, new address[](0), new address[](0));
    }
}