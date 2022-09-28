// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICToken {
    function underlying() external view returns (address);
    function symbol() external view returns (string memory);
}