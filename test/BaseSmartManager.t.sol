// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BaseSmartManager} from "../src/SmartManager/BaseSmartManager.sol";
import {ISmartManager} from "../src/SmartManager/interfaces/ISmartManager.sol";
import {BaseSmartNFT} from "../src/SmartNFT/BaseSmartNFT.sol";

contract BaseSmartManagerTest is Test {
    BaseSmartManager public smartManager;
    string public baseUrl = "https://baseurl.com/";
    uint256 public baseTotalSupply = 100;
    bytes public baseSmartNFTCteationCode = type(BaseSmartNFT).creationCode;
    address public deployer;
    address public nonOwner = address(0x1234);

    function setUp() public {
        deployer = msg.sender;
        vm.prank(deployer);
        smartManager = new BaseSmartManager(baseUrl);
    }

    function test_Deploy() public {
        assertEq(smartManager.owner(), deployer);
        assertEq(smartManager.uri(0), baseUrl);
        assertEq(smartManager.tokenIdCounter(), 0);
        assertEq(smartManager.isValidator(deployer), true);
    }

    function test_Register() public {
        vm.prank(deployer);

        uint256 tokenId;
        address implAddr;
        (tokenId, implAddr) = smartManager.register(
            baseSmartNFTCteationCode,
            baseTotalSupply
        );

        assertEq(tokenId, 1);
        assertEq(smartManager.smartNFTTokenIdOf(implAddr), tokenId);
        assertEq(smartManager.balanceOf(deployer, tokenId), baseTotalSupply);

        BaseSmartManager.SmartNFTInfo memory info = smartManager.smartNFTInfoOf(
            tokenId
        );
        assertEq(info.implAddr, implAddr);
        assertEq(
            uint256(info.status),
            uint256(ISmartManager.VerificationStatus.UNVERIFIED)
        );
        assertEq(info.registerTime, block.timestamp);
        assertEq(info.auditTime, 0);
    }

    function test_AuditTo() public {
        vm.prank(deployer);

        address[] memory validators = new address[](1);
        address newValidator = address(0x1234);
        validators[0] = newValidator;

        smartManager.setValidators(validators, true);
        assertEq(smartManager.isValidator(newValidator), true);

        vm.prank(deployer);
        smartManager.setValidators(validators, false);
        assertEq(smartManager.isValidator(newValidator), false);
    }

    function test_AuditTo_RevetIF_CalledByNonOwner() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                nonOwner
            )
        );
        vm.prank(nonOwner);

        address[] memory validators = new address[](1);
        address newValidator = address(0x1234);
        validators[0] = newValidator;
        smartManager.setValidators(validators, true);
    }

    function test_IsAccessible() public {
        vm.prank(deployer);

        uint256 tokenId;
        address implAddr;
        (tokenId, implAddr) = smartManager.register(
            baseSmartNFTCteationCode,
            baseTotalSupply
        );
        assertEq(smartManager.isAccessible(deployer, tokenId), false);
        assertEq(smartManager.isAccessible(nonOwner, tokenId), false);

        vm.prank(deployer);
        smartManager.auditTo(tokenId, true);
        assertEq(smartManager.isAccessible(deployer, tokenId), true);
        assertEq(smartManager.isAccessible(nonOwner, tokenId), false);
    }

    function test_SetValidators_RevertIf_CalledByNonOwner() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                nonOwner
            )
        );

        vm.prank(nonOwner);

        address[] memory validators = new address[](1);
        address newValidator = address(0x1234);
        validators[0] = newValidator;

        smartManager.setValidators(validators, true);
    }

    function test_SetValidators_RevertIf_EmptyValidators() public {
        vm.expectRevert("INVALID VALIDATORS");
        vm.prank(deployer);

        address[] memory validators = new address[](0);

        smartManager.setValidators(validators, true);
    }
}
