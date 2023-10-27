// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {Test, console2} from "forge-std/Test.sol";
import {TestSmartNFT} from "@test/TestSmartNFT.sol";
import {TestSmartManager} from "@test/TestSmartManager.sol";
import {BaseIntentProxy} from "@intent-proxy/BaseIntentProxy.sol";

contract BaseIntentProxyTest is Test {
    BaseIntentProxy public intentProxy;
    TestSmartManager public smartManager;
    TestSmartNFT public smartNFT;

    function setUp() public {
        smartNFT = new TestSmartNFT();
        smartManager = new TestSmartManager();
        intentProxy = new BaseIntentProxy(address(smartManager));

        smartManager.setSmartNFTInfo(1, address(smartNFT));
    }

    function test_Deploy() public {
        assertEq(intentProxy.SMART_MANAGER(), address(smartManager));
    }

    function test_ExecuteIntent() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 1;
        tokenIds[1] = 1;

        bytes[] memory actions = new bytes[](2);
        actions[0] = abi.encode(0x01);
        actions[1] = abi.encode(0x02);

        assertEq(intentProxy.executeIntent(tokenIds, actions), true);
    }
}
