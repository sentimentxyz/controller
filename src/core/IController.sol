// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IController {
    function canCall(
        address target,
        bool useEth,
        bytes calldata data
    ) external view returns (bool, address[] memory, address[] memory);
}
