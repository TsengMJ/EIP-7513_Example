// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC20/IERC20.sol";
import "@smart-manager/interfaces/ISmartManager.sol";
import "./BaseSmartNFT.sol";

contract TransferERC20SmartNFT is BaseSmartNFT {
    struct ExecuteParam {
        address token; // ERC-20 token address
        address to; // The address of the recipient
        uint256 amount; // The number of tokens transferred
    }

    constructor(
        address manager_,
        uint256 tokenId_
    ) BaseSmartNFT(manager_, tokenId_) {}

    function _execute(bytes memory data) internal override {
        ExecuteParam memory param;
        param = abi.decode(data, (ExecuteParam));

        IERC20(param.token).transfer(param.to, param.amount);
    }
}
