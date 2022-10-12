// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";
import {IVault} from "./IVault.sol";

/**
    @title Balancer V2 Controller
    @notice Balance v2 controller for join/exit/swap/batchSwap (multiHop)
*/
contract BalancerController is IController {

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice joinPool(bytes32,address,address,(address[],uint256[],bytes,bool))
    bytes4 constant JOIN = 0xb95cac28;

    /// @notice exitPool(bytes32,address,address,(address[],uint256[],bytes,bool))
    bytes4 constant EXIT = 0x8bdb3913;

    /// @notice swap((bytes32,uint8,address,address,uint256,bytes),(address,bool,address,bool),uint256,uint256)
    bytes4 constant SWAP = 0x52bbbe29;

    /* -------------------------------------------------------------------------- */
    /*                              EXTERNAL FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address target, bool useEth, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        if (sig == JOIN)
            return canJoin(target, useEth, data[4:]);
        if (sig == EXIT)
            return canExit(target, useEth, data[4:]);
        if (sig == SWAP)
            return canSwap(target, useEth, data[4:]);
        return (false, new address[](0), new address[](0));
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

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
            true,
            tokensIn,
            tokensOut
        );
    }

    function canExit(address target, bool, bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (
            bytes32 poolId,
            ,
            ,
            IVault.ExitPoolRequest memory request
        ) = abi.decode(data, (
                bytes32, address, address, IVault.ExitPoolRequest
            )
        );
        address[] memory tokensOut = new address[](1);
        address[] memory tokensIn = new address[](request.assets.length);

        uint i; uint j;
        while(i < request.assets.length) {
            if (address(request.assets[i]) != address(0))
                tokensIn[j++] = address(request.assets[i]);
            unchecked { ++i; }
        }
        assembly { mstore(tokensIn, j) }

        (tokensOut[0],) = IVault(target).getPool(poolId);

        return (
            true,
            tokensIn,
            tokensOut
        );
    }

    function canSwap(address, bool, bytes calldata data)
        internal
        pure
        returns (bool, address[] memory, address[] memory)
    {
        (
            IVault.SingleSwap memory swap,
            ,
            ,
        ) = abi.decode(data, (
                IVault.SingleSwap, IVault.FundManagement, uint256, uint256
            )
        );

        address[] memory tokensIn;
        address[] memory tokensOut;

        if (address(swap.assetIn) == address(0)) {
            tokensIn = new address[](1);
            tokensIn[0] = address(swap.assetOut);
            return (
                true,
                tokensIn,
                new address[](0)
            );
        }

        if (address(swap.assetOut) == address(0)) {
            tokensOut = new address[](1);
            tokensOut[0] = address(swap.assetIn);
            return (
                true,
                new address[](0),
                tokensOut
            );
        }

        tokensIn = new address[](1);
        tokensOut = new address[](1);
        tokensOut[0] = address(swap.assetIn);
        tokensIn[0] = address(swap.assetOut);

        return (
            true,
            tokensIn,
            tokensOut
        );
    }
}