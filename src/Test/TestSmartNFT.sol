// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TestSmartNFT {
    function execute(bytes memory data) external payable returns (bool) {
        require(data.length > 0, "empty data");
        return true;
    }
}
