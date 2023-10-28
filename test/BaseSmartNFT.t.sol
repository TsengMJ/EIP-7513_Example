// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BaseSmartManager} from "../src/SmartManager/BaseSmartManager.sol";
import {ISmartManager} from "../src/SmartManager/interfaces/ISmartManager.sol";
import {BaseSmartNFT} from "../src/SmartNFT/BaseSmartNFT.sol";

contract BaseSmartNFTTest is Test {
    BaseSmartManager public smartManager;
    BaseSmartNFT public smartNFT;

    string public baseUrl = "https://baseurl.com/";
    uint256 public baseTotalSupply = 100;
    bytes public cteationCode = type(BaseSmartNFT).creationCode;
    address public deployer;
    address public nonOwner = address(0x1234);

    function setUp() public {
        deployer = msg.sender;
        vm.prank(deployer);
        smartManager = new BaseSmartManager(baseUrl);

        vm.prank(deployer);
        (, address implAddr) = smartManager.register(
            cteationCode,
            baseTotalSupply
        );
        smartNFT = BaseSmartNFT(implAddr);
    }

    function test_Deploy() public {
        vm.prank(deployer);
        (uint256 tokenId, address implAddr) = smartManager.register(
            cteationCode,
            baseTotalSupply
        );

        assertEq(BaseSmartNFT(implAddr).TOKEN_ID(), tokenId);
        assertEq(BaseSmartNFT(implAddr).SMART_MANAGER(), address(smartManager));
        assertEq(BaseSmartNFT(implAddr).CURRENT_ADDRESS(), implAddr);
    }

    function test_Execute() public {
        uint256 tokenId = 1;
        vm.prank(deployer);
        smartManager.auditTo(tokenId, true);

        vm.prank(deployer);
        bytes memory executeParam = abi.encode(0x0);
        assertEq(smartNFT.execute(executeParam), true);
    }
}
