// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ICToken {
    function underlying() external view returns (address);
}