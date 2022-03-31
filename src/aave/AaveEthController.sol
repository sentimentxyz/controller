// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {IController} from "../core/IController.sol";

contract AaveEthController is IController {
    bytes4 public constant DEPOSIT = 0x474cf53d;
    bytes4 public constant WITHDRAW = 0x80500d20;

    address public aWeth;

    constructor(address _aWeth) {
        aWeth = _aWeth;
    }

    function canCall(address, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    { 
        bytes4 sig = bytes4(data);
        if (sig == DEPOSIT) {
            address[] memory tokensIn = new address[](1);
            tokensIn[0] = aWeth;
            return (true, tokensIn, new address[](0));
        }
        if (sig == WITHDRAW) {
            address[] memory tokensOut = new address[](1);
            tokensOut[0] = aWeth;
            return (true, new address[](0), tokensOut);
        }
        return (false, new address[](0), new address[](0));
    }
}