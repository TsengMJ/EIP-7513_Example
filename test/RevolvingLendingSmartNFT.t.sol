// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BaseSmartManager} from "../src/SmartManager/BaseSmartManager.sol";
import {ISmartManager} from "../src/SmartManager/interfaces/ISmartManager.sol";
import {RevolvingLendingSmartNFT} from "../src/SmartNFT/RevolvingLendingSmartNFT.sol";
import {IIntentProxy} from "../src/IntentProxy/interfaces/IIntentProxy.sol";
import {BaseIntentProxy} from "../src/IntentProxy/BaseIntentProxy.sol";
import {TestERC20} from "@test/TestERC20.sol";

contract RevolvingLendingSmartNFTTest is Test {
    uint256 scrollTestnetFork;
    BaseSmartManager public smartManager;
    RevolvingLendingSmartNFT public smartNFT;
    TestERC20 public token;
    BaseIntentProxy public intentProxy;

    string public baseUrl = "https://baseurl.com/";
    uint256 public baseTotalSupply = 100;
    bytes public cteationCode = type(RevolvingLendingSmartNFT).creationCode;
    address public deployer = address(0xabcd);
    address public nonOwner = address(0x1234);

    function setUp() public {
        scrollTestnetFork = vm.createFork("https://sepolia-rpc.scroll.io");
        vm.selectFork(scrollTestnetFork);

        vm.startPrank(deployer);

        smartManager = new BaseSmartManager(baseUrl);
        intentProxy = new BaseIntentProxy(address(smartManager));
        token = new TestERC20();

        (uint256 tokenId, address implAddr) = smartManager.register(
            cteationCode,
            baseTotalSupply
        );

        smartManager.auditTo(tokenId, true);
        smartManager.safeTransferFrom(
            deployer,
            address(intentProxy),
            tokenId,
            1,
            ""
        );

        smartNFT = RevolvingLendingSmartNFT(implAddr);

        vm.stopPrank();
    }

    function test_Deploy() public {
        vm.startPrank(deployer);
        (uint256 tokenId, address implAddr) = smartManager.register(
            cteationCode,
            baseTotalSupply
        );

        assertEq(RevolvingLendingSmartNFT(implAddr).TOKEN_ID(), tokenId);
        assertEq(
            RevolvingLendingSmartNFT(implAddr).SMART_MANAGER(),
            address(smartManager)
        );
        assertEq(
            RevolvingLendingSmartNFT(implAddr).CURRENT_ADDRESS(),
            implAddr
        );

        vm.stopPrank();
    }

    function test_Execute() public {
        vm.selectFork(scrollTestnetFork);
        vm.startPrank(deployer);

        address aave = 0xfc2921bE7B2762F0E87039905d6019B0fF5978a8;
        address usdc = 0x2C9678042D52B97D27f2bD2947F7111d93F3dD0D;

        deal(address(usdc), address(intentProxy), 100 ether);

        uint256 tokenId = 1;
        smartManager.auditTo(tokenId, true);

        bytes memory executeParam = abi.encode(
            RevolvingLendingSmartNFT.ExecuteParam({
                count: 2,
                amountIn: 10000000,
                to: deployer,
                inputAsset: usdc,
                outputAsset: aave
            })
        );

        IIntentProxy.Action[] memory actions = new IIntentProxy.Action[](1);
        actions[0] = IIntentProxy.Action(tokenId, executeParam);

        assertEq(intentProxy.executeIntent(actions), true);
        assertGt(IERC20(aave).balanceOf(address(intentProxy)), 0);

        vm.stopPrank();
    }
}
