// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IStableSwapPool {
    function coins(uint256 i) external view returns (address);
    function token() external view returns (address);
    function lp_token() external view returns (address);
}