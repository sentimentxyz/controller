// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IStableSwapPool {
    function coins(uint256 i) external view returns (address);
    function token() external view returns (address);
}