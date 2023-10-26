// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ISmartNFT {
    /**
     * @dev Proxy call `execute` function by delegateCall
     *
     * SmartNFT MUST implement a `execute` function
     *
     * @param data           The data required by the execute function
     * @return ret           The result of the execution
     */
    function execute(bytes memory data) external payable returns (bool);

    /**
     * @dev Validate that the caller has permission to call `execute` function
     *
     * SmartNFT MUST implement a `validatePermission` function
     *
     * SmartNFT can query whether caller has permission by call `isAccessible` of the SmartManager
     *
     * @return ret           True or False
     */
    function validatePermission() external view returns (bool);
}
