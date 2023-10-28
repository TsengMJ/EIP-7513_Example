// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BaseSmartManager} from "../src/SmartManager/BaseSmartManager.sol";
import {ISmartManager} from "../src/SmartManager/interfaces/ISmartManager.sol";
import {TransferERC20SmartNFT} from "../src/SmartNFT/TransferERC20SmartNFT.sol";
import {BaseIntentProxy} from "../src/IntentProxy/BaseIntentProxy.sol";
import {TestERC20} from "@test/TestERC20.sol";

contract TransferERC20SmartNFTTest is Test {
    BaseSmartManager public smartManager;
    TransferERC20SmartNFT public smartNFT;
    TestERC20 public token;
    BaseIntentProxy public intentProxy;

    string public baseUrl = "https://baseurl.com/";
    uint256 public baseTotalSupply = 100;
    bytes public cteationCode = type(TransferERC20SmartNFT).creationCode;
    address public deployer = address(0xabcd);
    address public nonOwner = address(0x1234);

    function setUp() public {
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

        smartNFT = TransferERC20SmartNFT(implAddr);

        vm.stopPrank();
    }

    function test_Deploy() public {
        vm.startPrank(deployer);
        (uint256 tokenId, address implAddr) = smartManager.register(
            cteationCode,
            baseTotalSupply
        );

        assertEq(TransferERC20SmartNFT(implAddr).TOKEN_ID(), tokenId);
        assertEq(
            TransferERC20SmartNFT(implAddr).SMART_MANAGER(),
            address(smartManager)
        );
        assertEq(TransferERC20SmartNFT(implAddr).CURRENT_ADDRESS(), implAddr);

        vm.stopPrank();
    }

    function test_Execute() public {
        vm.startPrank(deployer);

        deal(address(token), address(intentProxy), 100 ether);

        uint256 tokenId = 1;
        smartManager.auditTo(tokenId, true);

        bytes memory executeParam = abi.encode(
            TransferERC20SmartNFT.ExecuteParam({
                token: address(token),
                to: address(nonOwner),
                amount: 1
            })
        );

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = tokenId;
        tokenIds[1] = tokenId;

        bytes[] memory actions = new bytes[](2);
        actions[0] = executeParam;
        actions[1] = executeParam;

        assertEq(intentProxy.executeIntent(tokenIds, actions), true);
        assertEq(token.balanceOf(address(nonOwner)), 2);

        vm.stopPrank();
    }
}
