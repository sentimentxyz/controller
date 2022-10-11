// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IController} from "../core/IController.sol";

interface IChildGauge {
    function lp_token() external view returns (address);
    function reward_count() external view returns (uint256);
    function reward_tokens(uint256) external view returns (address);
}

/**
    @title Curve LP staking controller
    @notice Interaction controller for staking curve LP controllers
*/
contract CurveLPStakingController is IController {

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice deposit(uint256)
    bytes4 constant DEPOSIT = 0xb6b55f25;

    /// @notice withdraw(uint256)
    bytes4 constant WITHDRAW = 0x2e1a7d4d;

    /// @notice claim_rewards()
    bytes4 constant CLAIM = 0xe6f1daf2;

    /* -------------------------------------------------------------------------- */
    /*                             EXTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address target, bool, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);
        if (sig == DEPOSIT) {
            address[] memory tokensIn = new address[](1);
            address[] memory tokensOut = new address[](1);
            tokensIn[0] = target;
            tokensOut[0] = IChildGauge(target).lp_token();
            return (true, tokensIn, tokensOut);
        }
        if (sig == WITHDRAW) {
            address[] memory tokensIn = new address[](1);
            address[] memory tokensOut = new address[](1);
            tokensOut[0] = target;
            tokensIn[0] = IChildGauge(target).lp_token();
            return (true, tokensIn, tokensOut);
        }
        if (sig == CLAIM) {
            uint count = IChildGauge(target).reward_count();
            if (count == 0) return (false, new address[](0), new address[](0));
            address[] memory tokensIn = new address[](count);
            for (uint i; i<count; i++)
                tokensIn[i] = IChildGauge(target).reward_tokens(i);
            
            return (true, tokensIn, new address[](0));
        }
        return (false, new address[](0), new address[](0));
    }
}