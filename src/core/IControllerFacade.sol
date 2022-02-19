// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IControllerFacade {
    function isSwapAllowed(address token) external view returns (bool);
    
    function canCall(
        address target,
        bytes calldata data
    ) external view returns (bool, address[] memory, address[] memory);
    
    function canCallBatch(
        address[] calldata target,
        bytes[] calldata data
    ) external view returns (bool, address[] memory, address[] memory);
}
