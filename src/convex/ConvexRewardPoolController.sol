// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";

interface ICurveGauge {
    function lp_token() external view returns (address);
}

interface IRewardPool {
    function curveGauge() external view returns (address);
    function rewardLength() external view returns (uint256);
    function rewards(uint index) external view returns (RewardType memory);
}

struct RewardType {
    address reward_token;
    uint128 reward_integral;
    uint128 reward_remaining;
}

contract ConvexRewardPoolController is IController {

    /// @notice withdraw(uint256, bool)
    bytes4 WITHDRAW = 0x38d07436;

    /// @notice getReward(address)
    bytes4 GET_REWARD = 0xc00007b0;

    function canCall(address target, bool, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        bytes4 sig = bytes4(data);

        if (sig == WITHDRAW) return canWithdraw(target, data[4:]);
        if (sig == GET_REWARD) return canGetReward(target);

        return (false, new address[](0), new address[](0));
    }

    function canWithdraw(address rewardPool, bytes calldata data)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        (, bool claim) = abi.decode(data, (uint, bool));

        uint rewardsLen = (claim) ? IRewardPool(rewardPool).rewardLength() : 0;
        address[] memory tokensIn = new address[](rewardsLen + 1);

        if (rewardsLen > 0) {
            for(uint i; i < rewardsLen; ++i) {
                tokensIn[i] = IRewardPool(rewardPool).rewards(i).reward_token;
            }
        }

        tokensIn[rewardsLen] = ICurveGauge(IRewardPool(rewardPool).curveGauge()).lp_token();

        address[] memory tokensOut = new address[](1);
        tokensOut[0] = rewardPool;

        return (true, tokensIn, tokensOut);
    }

    function canGetReward(address rewardPool)
        internal
        view
        returns (bool, address[] memory, address[] memory)
    {
        uint len = IRewardPool(rewardPool).rewardLength();
        address[] memory tokensIn = new address[](len);

        for(uint i; i < len; ++i) {
            tokensIn[i] = IRewardPool(rewardPool).rewards(i).reward_token;
        }

        return (true, tokensIn, new address[](0));
    }
}