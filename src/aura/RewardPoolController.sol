// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";
import {IERC4626} from "../erc4626/IERC4626.sol";
import {IRewards} from "./IRewards.sol";
import {IBooster} from "./IBooster.sol";

/**
 * @title Aura reward pool controller
 */
contract RewardPoolController is IController {
    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice deposit(uint256,address)
    bytes4 constant DEPOSIT = 0x6e553f65;

    /// @notice mint(uint256,address)
    bytes4 constant MINT = 0x94bf804d;

    /// @notice redeem(uint256,address,address)
    bytes4 constant REDEEM = 0xba087652;

    /// @notice withdraw(uint256,address,address)
    bytes4 constant WITHDRAW = 0xb460af94;

    /// @notice getReward()
    bytes4 constant GET_REWARD = 0x3d18b912;

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

        if (sig == DEPOSIT || sig == MINT) {
            return canCallDepositAndMint(target);
        }

        if (sig == REDEEM || sig == WITHDRAW) {
            return canCallWithdrawAndRedeem(target);
        }

        if (sig == GET_REWARD) {
            return canCallGetReward(target);
        }

        return (false, new address[](0), new address[](0));
    }

    function canCallDepositAndMint(address target) internal view returns (bool, address[] memory, address[] memory) {
        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](1);
        tokensIn[0] = target;
        tokensOut[0] = IERC4626(target).asset();
        return (true, tokensIn, tokensOut);
    }

    function canCallWithdrawAndRedeem(address target)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        address[] memory tokensIn = new address[](1);
        address[] memory tokensOut = new address[](1);
        tokensIn[0] = IERC4626(target).asset();
        tokensOut[0] = target;
        return (true, tokensIn, tokensOut);
    }

    function canCallGetReward(address target) internal view returns (bool, address[] memory, address[] memory) {
        uint256 rewardLength = IRewards(target).extraRewardsLength();
        address[] memory tokensIn = new address[](rewardLength + 2);
        for (uint256 i = 0; i < rewardLength; i++) {
            tokensIn[i] = IRewards(IRewards(target).extraRewards(i)).rewardToken();
        }
        tokensIn[rewardLength] = IRewards(target).rewardToken();
        tokensIn[rewardLength + 1] = IBooster(IRewards(target).operator()).minter();
        return (true, tokensIn, new address[](0));
    }
}
