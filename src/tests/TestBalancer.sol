// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "src/core/ControllerFacade.sol";
import "src/core/IControllerFacade.sol";
import "src/balancer/BalancerController.sol";
import "src/balancer/interface/IVault.sol";
import "ds-test/Test.sol";

contract TestBalancer is DSTest {

    ControllerFacade controllerFacade;
    BalancerController balancerController;

    address vault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    function setUp() public {
        controllerFacade = new ControllerFacade();
        balancerController = new BalancerController(controllerFacade);
        controllerFacade.updateController(vault, balancerController);
        controllerFacade.toggleTokenAllowance(0x32296969Ef14EB0c6d29669C550D4a0449130230);
    }

    function testCanCall() public {
        bytes32 poolId = 0x32296969ef14eb0c6d29669c550d4a0449130230000200000000000000000080;
        address sender = 0xABBb9Eb2512904123f9d372f26e2390a190d8550;
        address receiver = 0xABBb9Eb2512904123f9d372f26e2390a190d8550;

        IAsset[] memory assets = new IAsset[](2);
        assets[0] = IAsset(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0);
        assets[1] = IAsset(address(0));

        uint256[] memory maxAmountsIn = new uint256[](2);
        maxAmountsIn[0] = 0;
        maxAmountsIn[1] = 23200000000000000000;

        bytes memory userData = "000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000013d76dd2f55e7a75f0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000141f6f514c5100000";

        bool internalBalance = false;

        IVault.JoinPoolRequest memory request = IVault.JoinPoolRequest(
            assets,
            maxAmountsIn,
            userData,
            internalBalance
        );

        bytes memory data = abi.encodeWithSelector(0xb95cac28,
            poolId,
            sender,
            receiver,
            request
        );

        controllerFacade.canCall(vault, true, data);
    }
}
