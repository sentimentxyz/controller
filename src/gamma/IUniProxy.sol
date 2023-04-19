// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

interface IUniProxy {
    function deposit(uint256 deposit0, uint256 deposit1, address to, address pos, uint256[4] memory minIn)
        external
        returns (uint256 shares);
}
