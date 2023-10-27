// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIntentProxy {
    error InvalidIntentInputLength();

    error EmptyActions();

    error DelegateCallFailed(uint256 tokenId);

    function executeIntent(
        uint256[] memory tokenIds,
        bytes[] memory actions
    ) external payable returns (bool);
}
