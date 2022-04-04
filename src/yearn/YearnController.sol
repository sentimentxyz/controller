// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {IController} from "../core/IController.sol";

interface IYVault {
    function token() external view returns (address);
}

contract YearnVaultController is IController {
    bytes4 constant DEPOSIT = 0xb6b55f25;
    bytes4 constant WITHDRAW = 0x2e1a7d4d;

    function canCall(address target, bool, bytes calldata data)
        external 
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        if (sig == DEPOSIT) {
            address[] memory tokensIn = new address[](1);
            address[] memory tokensOut = new address[](1);

            tokensIn[0] = target;
            tokensOut[0] = IYVault(target).token();

            return (true, tokensIn, tokensOut);
        }
        if (sig == WITHDRAW) {
            address[] memory tokensIn = new address[](1);
            address[] memory tokensOut = new address[](1);

            tokensOut[0] = target;
            tokensIn[0] = IYVault(target).token();

            return (true, tokensIn, tokensOut);
        }

        return (false, new address[](0), new address[](0));
    }
}