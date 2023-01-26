// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IController} from "../core/IController.sol";

/**
    @title Base Controller
    @notice Base controller with no interactions
*/
contract BaseController is IController {

    /// @inheritdoc IController
    function canCall(address, bool, bytes calldata)
        external
        pure
        returns (bool, address[] memory, address[] memory)
    {
        return (false, new address[](0), new address[](0));
    }
}