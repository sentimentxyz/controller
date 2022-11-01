// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";
import {IVault, IAsset} from "./IVault.sol";

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
    bytes4 constant BATCH_SWAP = 0x945bcec9;

    /* -------------------------------------------------------------------------- */
    /*                              EXTERNAL FUNCTIONS                            */
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
        if (sig == BATCH_SWAP)
            return canBatchSwap(target, useEth, data[4:]);
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

    function canBatchSwap(address, bool, bytes calldata data)
        internal
        pure
        returns (bool, address[] memory, address[] memory)
    {
        (
            ,
            IVault.BatchSwapStep[] memory swaps,
            IAsset[] memory assets,
            ,
            ,
        ) = abi.decode(data, (
                uint8, IVault.BatchSwapStep[], IAsset[], IVault.FundManagement, uint256[], uint256
            )
        );

        if (!isMultiHopSwap(swaps))
            return (false, new address[](0), new address[](0));

        uint tokenInIndex = swaps[swaps.length - 1].assetOutIndex;
        uint tokenOutIndex = swaps[0].assetInIndex;

        address[] memory tokensIn;
        address[] memory tokensOut;

        if (address(assets[tokenOutIndex]) == address(0)) {
            tokensIn = new address[](1);
            tokensIn[0] = address(assets[tokenInIndex]);
            return (
                true,
                tokensIn,
                new address[](0)
            );
        }

        if (address(assets[tokenInIndex]) == address(0)) {
            tokensOut = new address[](1);
            tokensOut[0] = address(assets[tokenOutIndex]);
            return (
                true,
                new address[](0),
                tokensOut
            );
        }

        tokensIn = new address[](1);
        tokensOut = new address[](1);
        tokensOut[0] = address(assets[tokenOutIndex]);
        tokensIn[0] = address(assets[tokenInIndex]);

        return (
            true,
            tokensIn,
            tokensOut
        );
    }

    function isMultiHopSwap(IVault.BatchSwapStep[] memory swaps)
        internal
        pure
        returns (bool)
    {
        uint steps = swaps.length;
        for (uint i; i < steps - 1; i++) {
            if (swaps[i].assetOutIndex != swaps[i+1].assetInIndex)
                return false;
        }
        return true;
    }
}