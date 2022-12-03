// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPirexGMX {
    function depositGlp(
        address token,
        uint256 tokenAmount,
        uint256 minUsdg,
        uint256 minGlp,
        address receiver
    ) external returns (uint256, uint256, uint256);

    function redeemPxGlp(
        address token,
        uint256 amount,
        uint256 minOut,
        address receiver
    ) external returns (uint256, uint256, uint256);
}