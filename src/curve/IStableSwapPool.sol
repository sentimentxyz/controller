// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IStableSwapPool {
    function coins(uint256 i) external view returns (address);
    function get_dy(uint256, uint256, uint256) external view returns (uint256);
}