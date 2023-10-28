// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BaseSmartManager} from "../src/SmartManager/BaseSmartManager.sol";
import {ISmartManager} from "../src/SmartManager/interfaces/ISmartManager.sol";
import {SwapTokenWithUniSwapSmartNFT} from "../src/SmartNFT/SwapTokenWithUniSwapSmartNFT.sol";
import {BaseIntentProxy} from "../src/IntentProxy/BaseIntentProxy.sol";
import {TestERC20} from "@test/TestERC20.sol";

contract SwapTokenWithUniswapSmartNFTTest is Test {
    uint256 scrollTestnetFork;

    BaseSmartManager public smartManager;
    SwapTokenWithUniSwapSmartNFT public smartNFT;
    TestERC20 public token;
    BaseIntentProxy public intentProxy;

    string public baseUrl = "https://baseurl.com/";
    uint256 public baseTotalSupply = 100;
    bytes public cteationCode = type(SwapTokenWithUniSwapSmartNFT).creationCode;
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

        smartNFT = SwapTokenWithUniSwapSmartNFT(implAddr);

        vm.stopPrank();
    }

    function test_Deploy() public {
        vm.startPrank(deployer);
        (uint256 tokenId, address implAddr) = smartManager.register(
            cteationCode,
            baseTotalSupply
        );

        assertEq(SwapTokenWithUniSwapSmartNFT(implAddr).TOKEN_ID(), tokenId);
        assertEq(
            SwapTokenWithUniSwapSmartNFT(implAddr).SMART_MANAGER(),
            address(smartManager)
        );
        assertEq(
            SwapTokenWithUniSwapSmartNFT(implAddr).CURRENT_ADDRESS(),
            implAddr
        );

        vm.stopPrank();
    }

    function test_Execute() public {
        vm.selectFork(scrollTestnetFork);
        vm.startPrank(deployer);

        address wbtc = 0x5EA79f3190ff37418d42F9B2618688494dBD9693;
        address usdc = 0x2C9678042D52B97D27f2bD2947F7111d93F3dD0D;

        deal(wbtc, address(intentProxy), 100 ether);

        uint256 tokenId = 1;
        smartManager.auditTo(tokenId, true);

        address[] memory path = new address[](2);
        path[0] = wbtc;
        path[1] = usdc;
        bytes memory executeParam = abi.encode(
            SwapTokenWithUniSwapSmartNFT.ExecuteParam({
                amountIn: 1 ether,
                to: address(this),
                path: path,
                deadline: block.timestamp + 1000
            })
        );

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = tokenId;

        bytes[] memory actions = new bytes[](1);
        actions[0] = executeParam;

        assertEq(intentProxy.executeIntent(tokenIds, actions), true);
        assertEq(IERC20(wbtc).balanceOf(address(intentProxy)), 99 ether);

        vm.stopPrank();
    }
}
