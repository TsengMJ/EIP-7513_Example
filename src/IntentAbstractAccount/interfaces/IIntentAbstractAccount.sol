// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IIntentAbstractAccount {
    function executeIntent(
        address[] memory addrs,
        bytes[] memory actions
    ) external payable returns (bytes memory);
}
