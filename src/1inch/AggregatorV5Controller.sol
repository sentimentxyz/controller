// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";

interface Router {
    struct SwapDescription {
        address srcToken;
        address dstToken;
        address payable srcReceiver;
        address payable dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
    }
}

interface IUniswapPool {
    function token0() external view returns (address);

    function token1() external view returns (address);
}

contract AggregatorV5Controller is IController {
    /// @notice swap(address executor,tuple desc,bytes permit,bytes data)
    bytes4 constant SWAP = 0x12aa3caf;

    /// @notice uniswapV3Swap(uint256 amount,uint256 minReturn,uint256[] pools)
    bytes4 constant UNISWAPV3 = 0xe449022e;

    /// @notice clipperSwap(address clipperExchange,address srcToken,address dstToken,uint256 inputAmount,uint256 outputAmount,uint256 goodUntil,bytes32 r,bytes32 vs)
    bytes4 constant CLIPPERSWAP = 0x84bd6d29;

    address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint256 private constant _ONE_FOR_ZERO_MASK = 1 << 255;
    uint256 private constant _WETH_UNWRAP_MASK = 1 << 253;

    /// @inheritdoc IController
    function canCall(address, bool useEth, bytes calldata data)
        external
        view
        override
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        if (sig == SWAP) return canCallSwap(data[4:]);
        if (sig == UNISWAPV3) return canCallUniswapV3(useEth, data[4:]);
        if (sig == CLIPPERSWAP) return canCallClipperSwap(data[4:]);

        return (false, new address[](0), new address[](0));
    }

    function canCallClipperSwap(bytes calldata data)
        internal
        pure
        returns (bool, address[] memory tokensIn, address[] memory tokensOut)
    {
        (, address src, address dst,,,,,) =
            abi.decode(data, (address, address, address, uint256, uint256, uint256, bytes32, bytes32));

        if (dst == address(0)) {
            tokensIn = new address[](0);
        } else {
            tokensIn = new address[](1);
            tokensIn[0] = dst;
        }

        if (src == address(0)) {
            tokensOut = new address[](0);
        } else {
            tokensOut = new address[](1);
            tokensOut[0] = src;
        }

        return (true, tokensIn, tokensOut);
    }

    function canCallUniswapV3(bool useEth, bytes calldata data)
        internal
        view
        returns (bool, address[] memory tokensIn, address[] memory tokensOut)
    {
        (,, uint256[] memory pools) = abi.decode(data, (uint256, uint256, uint256[]));

        uint256 length = pools.length;
        uint256 lastIndex = length - 1;
        bool unwrapWeth = pools[lastIndex] & _WETH_UNWRAP_MASK > 0;

        if (!useEth && !unwrapWeth && length == 1) {
            uint256 pool = pools[0];
            bool zeroForOne = pool & _ONE_FOR_ZERO_MASK == 0;
            tokensIn = new address[](1);
            tokensOut = new address[](1);
            if (zeroForOne) {
                tokensIn[0] = IUniswapPool(address(uint160(pool))).token1();
                tokensOut[0] = IUniswapPool(address(uint160(pool))).token0();
            } else {
                tokensIn[0] = IUniswapPool(address(uint160(pool))).token0();
                tokensOut[0] = IUniswapPool(address(uint160(pool))).token1();
            }
            return (true, tokensIn, tokensOut);
        }

        if (useEth) {
            tokensOut = new address[](0);
        } else {
            tokensOut = new address[](1);
            uint256 pool = pools[0];
            bool zeroForOne = pool & _ONE_FOR_ZERO_MASK == 0;
            tokensOut[0] = zeroForOne
                ? IUniswapPool(address(uint160(pool))).token0()
                : IUniswapPool(address(uint160(pool))).token1();
        }

        if (unwrapWeth) {
            tokensIn = new address[](0);
        } else {
            tokensIn = new address[](1);
            uint256 pool = pools[lastIndex];
            bool zeroForOne = pool & _ONE_FOR_ZERO_MASK == 0;
            tokensIn[0] = zeroForOne
                ? IUniswapPool(address(uint160(pool))).token1()
                : IUniswapPool(address(uint160(pool))).token0();
        }

        return (true, tokensIn, tokensOut);
    }

    function canCallSwap(bytes calldata data)
        internal
        pure
        returns (bool, address[] memory tokensIn, address[] memory tokensOut)
    {
        (, Router.SwapDescription memory desc,,) = abi.decode(data, (address, Router.SwapDescription, bytes, bytes));

        if (desc.srcToken == ETH) {
            tokensOut = new address[](0);
        } else {
            tokensOut = new address[](1);
            tokensOut[0] = desc.srcToken;
        }

        if (desc.dstToken == ETH) {
            tokensIn = new address[](0);
        } else {
            tokensIn = new address[](1);
            tokensIn[0] = desc.dstToken;
        }

        return (true, tokensIn, tokensOut);
    }
}
