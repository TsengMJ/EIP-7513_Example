// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/access/Ownable.sol";
import "@openzeppelin/token/ERC1155/utils/ERC1155Holder.sol";
import "./interfaces/IIntentProxy.sol";

interface BaseSmartManager {
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

    function smartNFTInfoOf(
        uint256 tokenId
    ) external view returns (SmartNFTInfo memory);
}

contract BaseIntentProxy is IIntentProxy, Ownable, ERC1155Holder {
    address public immutable SMART_MANAGER;

    constructor(address smartManager_) Ownable(msg.sender) {
        SMART_MANAGER = smartManager_;
    }

    function executeIntent(
        uint256[] memory tokenIds,
        bytes[] memory actions
    ) external payable override returns (bool) {
        uint256 length = tokenIds.length;
        if (length != actions.length) {
            revert InvalidIntentInputLength();
        }
        if (length == 0) {
            revert EmptyActions();
        }

        BaseSmartManager.SmartNFTInfo memory info;
        for (uint256 i = 0; i < length; i++) {
            info = BaseSmartManager(SMART_MANAGER).smartNFTInfoOf(tokenIds[i]);

            (bool success, ) = info.implAddr.delegatecall(
                abi.encodeWithSignature("execute(bytes)", actions[i])
            );

            if (!success) {
                revert DelegateCallFailed(tokenIds[i]);
            }
        }

        return true;
    }
}
