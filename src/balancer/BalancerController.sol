// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "src/core/IController.sol";
import "src/core/IControllerFacade.sol";
import "./interface/IVault.sol";

contract BalancerController is IController {

    bytes4 constant JOIN = 0xb95cac28;

    IControllerFacade immutable controllerFacade;

    constructor(IControllerFacade _controller) {
        controllerFacade = _controller;
    }

    function canCall(address target, bool useEth, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        if (sig == JOIN) {
            return canJoin(target, useEth, data);
        }
        return (false, new address[](0), new address[](0));
    }

    function canJoin(address target, bool, bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (
            bytes32 poolId,
            ,
            ,
            IVault.JoinPoolRequest memory request
        ) = abi.decode(data, (
                bytes32, address, address, IVault.JoinPoolRequest
            )
        );

        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](request.assets.length);

        uint i; uint j;
        while(i < request.assets.length) {
            if (
                request.maxAmountsIn[i] > 0 &&
                address(request.assets[i]) != address(0)
            )
                tokensOut[j++] = address(request.assets[i]);
            unchecked { ++i; }
        }
        assembly { mstore(tokensOut, j) }

        (tokensIn[0],) = IVault(target).getPool(poolId);

        return (
            controllerFacade.isTokenAllowed(tokensIn[0]),
            tokensIn,
            tokensOut
        );
    }
}