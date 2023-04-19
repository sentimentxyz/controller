// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;

interface IHypervisor {
    function deposit(uint256 deposit0, uint256 deposit1, address to, address from, uint256[4] memory minIn)
        external
        returns (uint256);

    function withdraw(uint256 shares, address to, address from, uint256[4] memory minAmounts)
        external
        returns (uint256 amount0, uint256 amount1);

    function token0() external view returns (address);

    function token1() external view returns (address);
}
