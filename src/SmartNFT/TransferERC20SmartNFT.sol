// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./BaseSmartNFT.sol";
import "../SmartManager/interfaces/ISmartManager.sol";

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

    function execute(
        bytes memory data
    ) external payable override returns (bool) {
        require(validatePermission(), "invalid permission");

        ExecuteParam memory param;
        param = abi.decode(data, (ExecuteParam));

        IERC20(param.token).transfer(param.to, param.amount);

        return true;
    }
}
