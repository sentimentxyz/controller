// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IUniProxy.sol";
import "./IHypervisor.sol";
import "../core/IController.sol";

/**
 * @title Gamma Hypervisor controller
 */
contract HypervisorController is IController {
    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice withdraw(uint256 shares,address to,address from,uint256[4] minAmounts)
    bytes4 constant WITHDRAW = 0xa8559872;

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address target, bool, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        if (bytes4(data) == WITHDRAW) {
            address[] memory tokensIn = new address[](2);
            address[] memory tokensOut = new address[](1);
            tokensIn[0] = IHypervisor(target).token0();
            tokensIn[1] = IHypervisor(target).token1();
            tokensOut[0] = target;
            return (true, tokensIn, tokensOut);
        }

        return (false, new address[](0), new address[](0));
    }
}
