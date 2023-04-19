// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {TestBase} from "./utils/Base.t.sol";
import "../gamma/HypervisorController.sol";
import "../gamma/IHypervisor.sol";
import "../gamma/IUniProxy.sol";
import "../gamma/UniProxyController.sol";

contract TestGammaControllersArbi is TestBase {
    HypervisorController hypervisorController;
    UniProxyController uniProxyController;

    IHypervisor hypervisor = IHypervisor(0xfA392dbefd2d5ec891eF5aEB87397A89843a8260);
    IUniProxy uniProxy = IUniProxy(0x0A9C566EDA6641A308B4641d9fF99D20Ced50b24);

    function setUp() public override {
        super.setUp();
        controllerFacade.updateController(address(hypervisor), new HypervisorController());
        controllerFacade.updateController(address(uniProxy), new UniProxyController());
    }

    function testCanCallDeposit() public {
        controllerFacade.toggleTokenAllowance(address(hypervisor));
        bytes memory data = abi.encodeWithSelector(
            IUniProxy.deposit.selector,
            0,
            0,
            address(0),
            address(hypervisor),
            [uint256(0), uint256(0), uint256(0), uint256(0)]
        );
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(address(uniProxy), false, data);

        assertTrue(canCall);
        assertEq(tokensOut.length, 2);
        assertEq(tokensOut[0], hypervisor.token0());
        assertEq(tokensOut[1], hypervisor.token1());
        assertEq(tokensIn.length, 1);
        assertEq(tokensIn[0], address(hypervisor));
    }

    function testCanCallWithdraw() public {
        controllerFacade.toggleTokenAllowance(hypervisor.token0());
        controllerFacade.toggleTokenAllowance(hypervisor.token1());
        bytes memory data = abi.encodeWithSelector(
            IHypervisor.withdraw.selector,
            0,
            address(0),
            address(0),
            [uint256(0), uint256(0), uint256(0), uint256(0)]
        );
        (bool canCall, address[] memory tokensIn, address[] memory tokensOut) =
            controllerFacade.canCall(address(hypervisor), false, data);

        assertTrue(canCall);
        assertEq(tokensIn.length, 2);
        assertEq(tokensIn[0], hypervisor.token0());
        assertEq(tokensIn[1], hypervisor.token1());
        assertEq(tokensOut.length, 1);
        assertEq(tokensOut[0], address(hypervisor));
    }
}
