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

    /// @notice deposit(uint256,address,bool)
    bytes4 constant DEPOSITCLAIM = 0x83df6747;

    /// @notice withdraw(uint256)
    bytes4 constant WITHDRAW = 0x2e1a7d4d;

    /// @notice withdraw(uint256,address,bool)
    bytes4 constant WITHDRAWCLAIM = 0x00ebf5dd;

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

        if (sig == DEPOSIT) return canDeposit(target);
        if (sig == DEPOSITCLAIM) return canDepositAndClaim(target, data);
        if (sig == WITHDRAW) return canWithdraw(target);
        if (sig == WITHDRAWCLAIM) return canWithdrawAndClaim(target, data);
        if (sig == CLAIM) return canClaim(target);

        return (false, new address[](0), new address[](0));
    }

    function canDeposit(address target)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](1);
        tokensIn[0] = target;
        tokensOut[0] = IChildGauge(target).lp_token();
        return (true, tokensIn, tokensOut);
    }

    function canDepositAndClaim(address target, bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (,,bool claim) = abi.decode(
            data[4:], (uint256, address, bool)
        );
        if (!claim) return canDeposit(target);

        uint count = IChildGauge(target).reward_count();

        address[] memory tokensIn = new address[](count + 1);

        for (uint i; i<count; i++)
            tokensIn[i] = IChildGauge(target).reward_tokens(i);
        tokensIn[count] = target;

        address[] memory tokensOut = new address[](1);
        tokensOut[0] = IChildGauge(target).lp_token();

        return (true, tokensIn, tokensOut);
    }

    function canWithdraw(address target)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](1);
        tokensOut[0] = target;
        tokensIn[0] = IChildGauge(target).lp_token();
        return (true, tokensIn, tokensOut);
    }

    function canWithdrawAndClaim(address target, bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (,,bool claim) = abi.decode(
            data[4:], (uint256, address, bool)
        );

        if (!claim) return canWithdraw(target);

        uint count = IChildGauge(target).reward_count();

        address[] memory tokensIn = new address[](count + 1);
        for (uint i; i<count; i++)
            tokensIn[i] = IChildGauge(target).reward_tokens(i);
        tokensIn[count] = IChildGauge(target).lp_token();

        address[] memory tokensOut = new address[](1);
        tokensOut[0] = target;
        return (true, tokensIn, tokensOut);
    }

    function canClaim(address target)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        uint count = IChildGauge(target).reward_count();

        address[] memory tokensIn = new address[](count);
        for (uint i; i<count; i++)
            tokensIn[i] = IChildGauge(target).reward_tokens(i);

        return (true, tokensIn, new address[](0));
    }
}