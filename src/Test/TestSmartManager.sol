// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC1155/ERC1155.sol";
import "@openzeppelin/utils/math/Math.sol";
import "@openzeppelin/utils/cryptography/ECDSA.sol";
import "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/access/Ownable.sol";

// SmartManager contract, used for manage smartNFT contract
contract TestSmartManager is Ownable(address(0x1234)), ERC1155("test") {
    enum VerificationStatus {
        UNREGISTERED, // Status before registration
        DEREGISTERED, // Status after deregistration
        UNVERIFIED, // Status after registration and waiting for validators' audits
        VERIFIED, //Status after the manager approves to be valid
        DENIED //Status after the manager approves to be invalid
    }

    struct SmartNFTInfo {
        address implAddr; // The implementation address of the SmartNFT
        uint64 registerTime;
        uint64 auditTime;
        VerificationStatus status; // The verification status of the SmartNFT
    }

    mapping(uint256 => SmartNFTInfo) private _smartNFTInfos;

    function setSmartNFTInfo(uint256 tokenId, address implAddr) external {
        _smartNFTInfos[tokenId] = SmartNFTInfo({
            implAddr: implAddr,
            registerTime: uint64(block.timestamp),
            auditTime: 0,
            status: VerificationStatus.VERIFIED
        });
    }

    function smartNFTInfoOf(
        uint256 tokenId
    ) external view returns (SmartNFTInfo memory) {
        return _smartNFTInfos[tokenId];
    }
}
