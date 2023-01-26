// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";

/**
    @title Reward Router V2 Controller for minting and redeeming GLP
    @dev arbi:0xB95DB5B167D75e6d04227CfFFA61069348d271F5
*/
contract RewardRouterV2Controller is IController {

    /* -------------------------------------------------------------------------- */
    /*                              STORAGE VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice mintAndStakeGlpETH(uint256 _minUsdg,uint256 _minGlp)
    bytes4 constant mintAndStakeGlpETH = 0x53a8aa03;

    /// @notice mintAndStakeGlp(address _token,uint256 _amount,uint256 _minUsdg,uint256 _minGlp)
    bytes4 constant mintAndStakeGlp = 0x364e2311;

    /// @notice unstakeAndRedeemGlp(address _tokenOut,uint256 _glpAmount,uint256 _minOut,address _receiver)
    bytes4 constant unstakeAndRedeemGlp = 0x0f3aa554;

    /// @notice unstakeAndRedeemGlpETH(uint256,uint256,address)
    bytes4 constant unstakeAndRedeemGlpETH = 0xabb5e5e2;

    /// @notice Staked GLP: 0x5402B5F40310bDED796c7D0F3FF6683f5C0cFfdf
    address[] sGLP;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    constructor(address _SGLP) {
        sGLP.push(_SGLP);
    }

    /* -------------------------------------------------------------------------- */
    /*                             EXTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    function canCall(address, bool useEth, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        if (sig == mintAndStakeGlp) return canCallMint(data[4:]);
        if (sig == mintAndStakeGlpETH) return canCallMintEth(useEth);
        if (sig == unstakeAndRedeemGlp) return canCallRedeem(data[4:]);
        if (sig == unstakeAndRedeemGlpETH) return canCallRedeemEth();

        return (false, new address[](0), new address[](0));
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    function canCallMint(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        address[] memory tokensOut = new address[](1);
        (tokensOut[0],,,) = abi.decode(data, (address, uint256, uint256, uint256));

        return (true, sGLP, tokensOut);
    }

    function canCallMintEth(bool useEth)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        if (!useEth) return (false, new address[](0), new address[](0));
        return (true, sGLP, new address[](0));
    }

    function canCallRedeem(bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        address[] memory tokensIn = new address[](1);
        (tokensIn[0],,,) = abi.decode(data, (address, uint256, uint256, uint256));

        return (true, tokensIn, sGLP);
    }

    function canCallRedeemEth()
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        return (true, new address[](0), sGLP);
    }
}