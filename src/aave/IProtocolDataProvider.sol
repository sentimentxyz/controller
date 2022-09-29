// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IProtocolDataProvider {
    function getReserveTokensAddresses(address asset)
        external
        view
        returns (
            address aTokenAddress,
            address stableDebtTokenAddress,
            address variableDebtTokenAddress
        );
}