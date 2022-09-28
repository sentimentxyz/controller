// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC4626 {
    function previewRedeem(uint256 shares) external view returns (uint256 assets);
    function asset() external view returns (address asset);
}