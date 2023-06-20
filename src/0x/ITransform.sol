// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ITransformERC20Feature {
    struct Transformation {
        uint32 deploymentNonce;
        bytes data;
    }

    function transformERC20(
        address inputToken,
        address outputToken,
        uint256 inputTokenAmount,
        uint256 minOutputTokenAmount,
        Transformation[] calldata transformations
    ) external payable returns (uint256 outputTokenAmount);
}
