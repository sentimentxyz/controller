// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IUniProxy.sol";
import "./IHypervisor.sol";
import "../core/IController.sol";

/**
 * @title Gamma UniProxy controller
 */
contract UniProxyController is IController {
    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice deposit(uint256 deposit0,uint256 deposit1,address to,address pos,uint256[4] minIn)
    bytes4 constant DEPOSIT = 0x8e3c92e4;

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IController
    function canCall(address, bool, bytes calldata data)
        external
        view
        returns (bool, address[] memory, address[] memory)
    {
        if (bytes4(data) == DEPOSIT) {
            (,,, address pos,) = abi.decode(data[4:], (uint256, uint256, address, address, uint256[4]));
            address[] memory tokensOut = new address[](2);
            address[] memory tokensIn = new address[](1);
            tokensOut[0] = IHypervisor(pos).token0();
            tokensOut[1] = IHypervisor(pos).token1();
            tokensIn[0] = pos;
            return (true, tokensIn, tokensOut);
        }

        return (false, new address[](0), new address[](0));
    }
}
