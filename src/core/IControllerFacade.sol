// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IControllerFacade {
    function isTokenAllowed(address token) external view returns (bool);
    
    function canCall(
        address target,
        bool useEth,
        bytes calldata data
    ) external view returns (bool, address[] memory, address[] memory);
    
    function canCallBatch(
        address[] calldata target,
        bool[] calldata useEth,
        bytes[] calldata data
    ) external view returns (bool, address[] memory, address[] memory);
}
