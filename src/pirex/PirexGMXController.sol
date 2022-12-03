// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";
import {IPirexGMX} from "./IPirexGMX.sol";

contract PirexGMXController is IController {

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice depositGmx(uint256,address) function signature
    bytes4 public constant DEPOSITGMX = 0x437a8d0a;

    /// @notice depositGlpETH(uint256,uint256,address) function signature
    bytes4 public constant DEPOSITGLPETH = 0xf64d0094;

    /// @notice depositGlp(address,uint256,uint256,uint256,address) function signature
    bytes4 public constant DEPOSITGLP = 0xc2ae96ef;

    /// @notice redeemPxGlp(address,uint256,uint256,address) function signature
    bytes4 public constant REDEEMPXGLP = 0x414cc4ce;

    /// @notice redeemPxGlpETH(uint256,uint256,address) function signature
    bytes4 public constant REDEEMPXGLPETH = 0x6151f1b7;

    /// @notice address of PXGMX
    address immutable PXGMX;

    /// @notice address of PXGLP
    address immutable PXGLP;

    /// @notice address of GMX
    address immutable GMX;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _PXGMX address of PXGMX
        @param _PXGLP address of PXGLP
    */
    constructor(address _PXGMX, address _PXGLP, address _GMX) {
        PXGLP = _PXGLP;
        PXGMX = _PXGMX;
        GMX = _GMX;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address, bool useEth, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);
        if (sig == DEPOSITGMX) return canCallDepositGMX();
        if (sig == DEPOSITGLPETH) return canCallDepositGLPETH(useEth);
        if (sig == DEPOSITGLP) return canCallDepositGLP(data[4:]);
        if (sig == REDEEMPXGLP) return canCallRedeemPXGLP(data[4:]);
        if (sig == REDEEMPXGLPETH) return canCallRedeemPXGLPETH();
        return (false, new address[](0), new address[](0));
    }

    function canCallDepositGMX()
        internal
        view
        returns (bool, address[] memory tokensIn, address[] memory tokensOut)
    {
        tokensIn = new address[](1);
        tokensOut = new address[](1);
        tokensIn[0] = PXGMX;
        tokensOut[0] = GMX;
        return (true, tokensIn, tokensOut);
    }

    function canCallDepositGLPETH(bool useEth)
        internal
        view
        returns (bool, address[] memory tokensIn, address[] memory)
    {
        if (!useEth) return (false, new address[](0), new address[](0));
        tokensIn = new address[](1);
        tokensIn[0] = PXGLP;
        return (true, tokensIn, new address[](0));
    }

    function canCallDepositGLP(bytes calldata data)
        internal
        view
        returns (bool, address[] memory tokensIn, address[] memory tokensOut)
    {
        tokensIn = new address[](1);
        tokensOut = new address[](1);
        tokensIn[0] = PXGLP;
        (tokensOut[0],,,,) = abi.decode(data, (address, uint256, uint256, uint256, address));
        return (true, tokensIn, tokensOut);
    }

    function canCallRedeemPXGLPETH()
        internal
        view
        returns (bool, address[] memory, address[] memory tokensOut)
    {
        tokensOut = new address[](1);
        tokensOut[0] = PXGLP;
        return (true, new address[](0), tokensOut);
    }

    function canCallRedeemPXGLP(bytes calldata data)
        internal
        view
        returns (bool, address[] memory tokensIn, address[] memory tokensOut)
    {
        tokensIn = new address[](1);
        tokensOut = new address[](1);
        tokensOut[0] = PXGLP;
        (tokensIn[0],,,) = abi.decode(data, (address, uint256, uint256, address));
        return (true, tokensIn, tokensOut);
    }
}