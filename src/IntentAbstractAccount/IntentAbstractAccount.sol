// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IIntentAbstractAccount.sol";

contract IntentAbstractAccount is IIntentAbstractAccount {
    function executeIntent(
        address[] memory addrs,
        bytes[] memory actions
    ) external payable returns (bytes memory) {
        uint256 length = addrs.length;
        require(length == actions.length, "length not match");

        for (uint256 i = 0; i < length; i++) {
            (bool success, bytes memory returnData) = addrs[i].delegatecall(
                abi.encodeWithSignature("execute(bytes)", actions[i])
            );
            require(success, string(returnData));
        }
        return abi.encode(true);
    }
}
