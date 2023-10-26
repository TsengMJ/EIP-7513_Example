// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/ISmartNFT.sol";
import "../SmartManager/interfaces/ISmartManager.sol";

abstract contract BaseSmartNFT is ISmartNFT {
    address public immutable SMART_MANAGER;
    address public immutable CURRENT_ADDRESS;
    uint256 public immutable TOKEN_ID;

    /**
     * TODO: Define your own parameters structure
     *
     * For example (transafer ERC-20 tokens):
     *
     * struct ExecuteParam {
     *   address token; // ERC-20 token address
     *   address to; // The address of the recipient
     *   uint256 amount; // The number of tokens transferred
     * }
     */

    constructor(address manager_, uint256 tokenId_) {
        SMART_MANAGER = manager_;
        TOKEN_ID = tokenId_;
        CURRENT_ADDRESS = address(this);
    }

    function execute(
        bytes memory data
    ) external payable virtual override returns (bool) {
        /**
         * TODO: Steps to implement the logic of the execute function
         *
         * 1. Validate the permission
         * 2. Decode the parameters
         * 3. Implement your own logic
         * 4. Return the result
         * 5. (Optional) Emit an event
         *
         * Example:
         *
         * require(validatePermission(), "invalid permission");
         *
         * ExecuteParam memory param;
         * param = abi.decode(data, (ExecuteParam));
         *
         * IERC20(param.token).transfer(param.to, param.amount);
         *
         * return true;
         */
    }

    function validatePermission() public view virtual override returns (bool) {
        return ISmartManager(SMART_MANAGER).isAccessible(msg.sender, TOKEN_ID);
    }
}
