// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IUniV2Factory {
    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);
}