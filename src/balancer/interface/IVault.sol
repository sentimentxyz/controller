// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IAsset {}

interface IVault {
    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;

    struct JoinPoolRequest {
        IAsset[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    function getPool(bytes32 poolId) external view returns (address, uint8);
}