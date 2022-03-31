// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {IController} from "../core/IController.sol";

contract AaveEthController is IController {
    bytes4 public constant DEPOSIT = 0x474cf53d;
    bytes4 public constant WITHDRAW = 0x80500d20;

    address[] public tokens;

    constructor(address _aWeth) {
        tokens.push(_aWeth);
    }

    function canCall(address, bool, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    { 
        bytes4 sig = bytes4(data);
        if (sig == DEPOSIT) return (true, tokens, new address[](0));
        if (sig == WITHDRAW) return (true, new address[](0), tokens);
        return (false, new address[](0), new address[](0));
    }
}