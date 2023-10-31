// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIntentProxy {
    error EmptyActions();

    error DelegateCallFailed(uint256 tokenId);

    struct Action {
        uint256 tokenId;
        bytes executeParam;
    }

    function executeIntent(
        Action[] calldata actions
    ) external payable returns (bool);
}
