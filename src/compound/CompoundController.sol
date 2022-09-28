// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ICToken} from "./ICToken.sol";
import {IController} from "../core/IController.sol";

/**
    @title Compound Controller
    @notice Controller for compound interaction via cToken
    cEth - eth:0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5
    cDai - eth:0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643
*/
contract CompoundController is IController {

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice mint() function signature
    bytes4 constant MINT_ETH = 0x1249c58b;

    /// @notice mint(uint256) function signature
    bytes4 constant MINT_ERC20 = 0xa0712d68;

    /// @notice redeem(uint256) function signature
    bytes4 constant REDEEM = 0xdb006a75;

    // keccak256(abi.encodePacked("cETH"))
    bytes32 constant cETH =
        0xb3c46c78043b5ff6963757142af6c297cddb5a0d3d823357472228eb35c8e890;

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address target, bool, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);
        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](1);
        if(sig == MINT_ETH) {
            tokensIn[0] = target;
            return(true, tokensIn, new address[](0));
        }
        if(sig == MINT_ERC20) {
            tokensIn[0] = target;
            tokensOut[0] = ICToken(target).underlying();
            return(true, tokensIn, tokensOut);
        }
        if(sig == REDEEM) {
            tokensOut[0] = target;

            if (keccak256(abi.encodePacked(ICToken(target).symbol())) == cETH)
                return (true, new address[](0), tokensOut);

            tokensIn[0] = ICToken(target).underlying();
            return(true, tokensIn, tokensOut);
        }
        return (false, new address[](0), new address[](0));
    }
}