// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/console.sol";
import {Ownable} from "src/utils/Ownable.sol";
import {IController} from "src/core/IController.sol";
import {BytesLib} from "solidity-bytes-utils/BytesLib.sol";
import {INonfungiblePositionManager} from "./interface/INonfungiblePositionManager.sol";

contract UniV3LPController is IController, Ownable {
    using BytesLib for bytes;
    /* -------------------------------------------------------------------------- */
    /*                                  CONSTANTS                                 */
    /* -------------------------------------------------------------------------- */

    bytes4 constant MULTICALL = 0xac9650d8;
    bytes4 constant MINT = 0x88316456;
    bytes4 constant REFUND_ETH = 0x12210e8a;
    bytes4 constant INCREASE_LIQUIDITY = 0x219f5d17;
    bytes4 constant DECREASE_LIQUIDITY = 0x0c49ccbe;
    bytes4 constant UNWRAP_WETH = 0x49404b7c;
    bytes4 constant BURN = 0x42966c68;

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    INonfungiblePositionManager public immutable positionManager;
    address public immutable WETH;

    address[] public token;

    mapping(bytes => bool) isPoolEnabled;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    constructor(INonfungiblePositionManager _positionManager, address _WETH) Ownable(msg.sender) {
        positionManager = _positionManager;
        token.push(address(_positionManager));
        WETH = _WETH;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    function canCall(
        address,
        bool useEth,
        bytes calldata data
    )
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);
        if (sig == MULTICALL) return parseMultiCall(data[4:], useEth);
        if (sig == MINT) return parseMint(data[4:]);
        if (sig == INCREASE_LIQUIDITY) return parseIncreaseLiquidity(data[4:]);
        if (sig == BURN) return (true, new address[](0), token);
        return (false, new address[](0), new address[](0));
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    function parseMultiCall(bytes calldata data, bool useEth)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes[] memory calls = abi.decode(data, (bytes[]));
        bytes4 sig = bytes4(calls[0]);
        if (sig == MINT)
            return parseMintMultiCall(calls, useEth);
        if (sig == INCREASE_LIQUIDITY)
            return parseIncreaseLiquidityMultiCall(calls, useEth);
        if (sig == DECREASE_LIQUIDITY)
            return parseDecreaseLiquidityMultiCall(calls);

        return (false, new address[](0), new address[](0));
    }

    function parseMintMultiCall(
        bytes[] memory multiData,
        bool useEth
    )
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        if (multiData.length > 2)
            return (false, new address[](0), new address[](0));

        if (useEth && bytes4(multiData[1]) == REFUND_ETH) {
            INonfungiblePositionManager.MintParams memory mintParams = abi.decode(
                multiData[0].slice(4, multiData[0].length - 4),
                (INonfungiblePositionManager.MintParams)
            );

            if(!isPoolEnabled[abi.encode(mintParams.token0, mintParams.token1)])
                return (false, new address[](0), new address[](0));

            address[] memory tokensOut = new address[](1);
            tokensOut[0] = (mintParams.token0 == WETH) ? mintParams.token1 : mintParams.token0;

            return (true, token, tokensOut);
        }

        return (false, new address[](0), new address[](0));
    }

    function parseIncreaseLiquidityMultiCall(
        bytes[] memory multiData,
        bool useEth
    )
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        if (multiData.length > 2)
            return (false, new address[](0), new address[](0));

        if (useEth && bytes4(multiData[1]) == REFUND_ETH) {
            INonfungiblePositionManager.IncreaseLiquidityParams memory params =
            abi.decode(
                multiData[0].slice(4, multiData[0].length - 4),
                (INonfungiblePositionManager.IncreaseLiquidityParams)
            );

            (address token0, address token1) = getTokensFromTokenID(params.tokenId);

            address[] memory tokensOut = new address[](1);
            tokensOut[0] = (token0 == WETH) ? token1 : token0;

            return (true, new address[](0), tokensOut);
        }

        return (false, new address[](0), new address[](0));
    }

    function parseDecreaseLiquidityMultiCall(bytes[] memory multiData)
        internal
        view returns (bool, address[] memory, address[] memory)
    {
        INonfungiblePositionManager.DecreaseLiquidityParams memory params =
            abi.decode(
                multiData[0].slice(4, multiData[0].length - 4),
                (INonfungiblePositionManager.DecreaseLiquidityParams)
            );

        address[] memory tokensIn;

        if (multiData.length <= 2) {
            tokensIn = new address[](2);
            (tokensIn[0], tokensIn[1]) = getTokensFromTokenID(params.tokenId);
            return (true, tokensIn, new address[](0));
        }

        if (bytes4(multiData[2]) == UNWRAP_WETH) {
            tokensIn = new address[](1);
            (address token0, address token1) = getTokensFromTokenID(params.tokenId);
            tokensIn[0] = (token0 == WETH) ? token1 : token0;
        } else {
            tokensIn = new address[](2);
            (tokensIn[0], tokensIn[1]) = getTokensFromTokenID(params.tokenId);
        }

        if (bytes4(multiData[multiData.length - 1]) == BURN)
            return (true, tokensIn, token);

        return (true, tokensIn, new address[](0));
    }

    function parseIncreaseLiquidity(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        INonfungiblePositionManager.IncreaseLiquidityParams memory params =
            abi.decode(
                data,
                (INonfungiblePositionManager.IncreaseLiquidityParams)
            );
        address[] memory tokensOut = new address[](2);
        (tokensOut[0], tokensOut[1]) = getTokensFromTokenID(params.tokenId);

        return (true, new address[](0), tokensOut);
    }

    function parseMint(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        INonfungiblePositionManager.MintParams memory mintParams = abi.decode(
            data,
            (INonfungiblePositionManager.MintParams)
        );

        if(!isPoolEnabled[abi.encode(mintParams.token0, mintParams.token1)])
            return (false, new address[](0), new address[](0));

        address[] memory tokensOut = new address[](2);
        tokensOut[0] = mintParams.token0;
        tokensOut[1] = mintParams.token1;
        return (true, token, tokensOut);
    }

    function getTokensFromTokenID(
        uint256 tokenID
    )
        internal
        view
        returns (address, address)
    {
        (
            , // [0]
            , // [1]
            address token0, // [2]
            address token1, // [3]
            , // [4]
            , // [5]
            , // [6]
            , // [7]
            , // [8]
            , // [9]
            , // [10]
            // [11]
        ) = positionManager.positions(tokenID);
        return (token0, token1);
    }

    /* -------------------------------------------------------------------------- */
    /*                               ADMIN FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    function setPool(
        address token0,
        address token1,
        bool enable
    )
        external
        adminOnly
    {
        isPoolEnabled[abi.encode(token0, token1)] = enable;
        isPoolEnabled[abi.encode(token1, token0)] = enable;
    }
}