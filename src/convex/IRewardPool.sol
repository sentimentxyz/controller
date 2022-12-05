// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IRewardPool {
    function curveGauge() external view returns (address);
    function rewardLength() external view returns (uint256);
    function rewards(uint index) external view returns (RewardType memory);

    struct RewardType {
        address reward_token;
        uint128 reward_integral;
        uint128 reward_remaining;
    }
}
