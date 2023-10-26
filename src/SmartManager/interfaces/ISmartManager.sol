// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ISmartManager {
    // The verification stage of a SmartNFT
    enum VerificationStatus {
        UNREGISTERED, // Status before registration
        DEREGISTERED, // Status after deregistration
        UNVERIFIED, // Status after registration and waiting for validators' audits
        VERIFIED, //Status after the manager approves to be valid
        DENIED //Status after the manager approves to be invalid
    }

    event Register(
        uint256 tokenId,
        uint256 totalSupply,
        address autor,
        address implAddr
    );

    event Audit(uint256 tokenId, address validator, bool isValid);

    /**
     * @dev Developer can take initCode of an SmartNFT here to register and get a tokenId for it
     *
     * SmartManager MUST implement a `register` function
     *
     * @param initCode  The initCode of the SmartNFT
     * @param totalSupply The total supply of the SmartNFT
     */
    function register(
        bytes calldata initCode,
        uint256 totalSupply
    ) external returns (uint256 tokenId, address implAddr);

    /**
     * @dev Validator can audit the SmartNFT here
     *
     * @param tokenId  The tokenId of the SmartNFT
     * @param isValid  The audit results of the validators
     */
    function auditTo(uint256 tokenId, bool isValid) external returns (bool);

    /**
     * @dev Provide a interface to the SmartNFT for query caller's permission
     *
     * SmartManager MUST implement a `isAccessible` function
     *
     * SmartManager can set the rule that Proxy access the SmartNFT by delegateCall
     *
     * @param caller     The address of the caller
     * @param tokenId    The tokenId of the SmartNFT
     * @return isAccess  The validity of the smartNFT contract
     */
    function isAccessible(
        address caller,
        uint256 tokenId
    ) external view returns (bool);

    /**
     * @dev Get the verification status of a SmartNFT
     *
     * @param tokenId    The tokenId of the SmartNFT
     */
    function verificationStatusOf(
        uint256 tokenId
    ) external view returns (VerificationStatus);
}
