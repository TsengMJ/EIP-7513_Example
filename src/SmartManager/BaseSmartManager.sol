// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC1155/ERC1155.sol";
import "@openzeppelin/utils/math/Math.sol";
import "@openzeppelin/utils/cryptography/ECDSA.sol";
import "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/access/Ownable.sol";
import "./interfaces/ISmartManager.sol";

// SmartManager contract, used for manage smartNFT contract
contract BaseSmartManager is ISmartManager, Ownable, ERC1155 {
    using ECDSA for bytes32;
    using Math for uint256;

    struct SmartNFTInfo {
        address implAddr; // The implementation address of the SmartNFT
        uint64 registerTime;
        uint64 auditTime;
        VerificationStatus status; // The verification status of the SmartNFT
    }

    uint256 public tokenIdCounter;

    mapping(address => bool) private _validators;

    mapping(uint256 => SmartNFTInfo) private _smartNFTInfos;

    mapping(address => uint256) private _smartNFTTokenIds;

    modifier onlyValidator() {
        require(_validators[_msgSender()], "NOT VALIDATOR");
        _;
    }

    constructor(string memory url_) Ownable(msg.sender) ERC1155(url_) {
        _setValidator(_msgSender(), true);
    }

    function register(
        bytes calldata creationCode,
        uint256 totalSupply
    ) external returns (uint256 tokenId, address implAddr) {
        _beforeRegister();

        (tokenId, implAddr) = _register(creationCode, totalSupply);

        _afterRegister();

        emit Register(tokenId, totalSupply, _msgSender(), implAddr);
    }

    function _register(
        bytes calldata creationCode,
        uint256 totalSupply
    ) internal returns (uint256 tokenId, address implAddr) {
        tokenIdCounter += 1;
        tokenId = tokenIdCounter;

        implAddr = _deploy(creationCode, tokenId);
        _mint(_msgSender(), tokenId, totalSupply, "");

        _smartNFTInfos[tokenId] = SmartNFTInfo({
            implAddr: implAddr,
            status: VerificationStatus.UNVERIFIED,
            registerTime: uint64(block.timestamp),
            auditTime: 0
        });

        _smartNFTTokenIds[implAddr] = tokenId;
    }

    function _deploy(
        bytes memory creationCode,
        uint256 tokenId
    ) internal returns (address) {
        bytes memory initCode = abi.encodePacked(
            creationCode,
            abi.encode(address(this), tokenId)
        );

        address addr;
        assembly {
            addr := create2(0, add(initCode, 0x20), mload(initCode), tokenId)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
        return addr;
    }

    function auditTo(
        uint256 tokenId,
        bool isValid
    ) external override onlyValidator returns (bool) {
        _audit(tokenId, isValid);

        emit Audit(tokenId, _msgSender(), isValid);
        return true;
    }

    function _audit(uint256 tokenId, bool isValid) internal {
        if (isValid) {
            _smartNFTInfos[tokenId].status = VerificationStatus.VERIFIED;
        } else {
            _smartNFTInfos[tokenId].status = VerificationStatus.DENIED;
        }
    }

    function isAccessible(
        address caller,
        uint256 tokenId
    ) external view override returns (bool) {
        return
            _smartNFTInfos[tokenId].status == VerificationStatus.VERIFIED &&
            balanceOf(caller, tokenId) > 0;
    }

    function setValidators(
        address[] calldata validators,
        bool isValid
    ) public onlyOwner {
        require(validators.length > 0, "INVALID VALIDATORS");
        for (uint256 i = 0; i < validators.length; i++) {
            _setValidator(validators[i], isValid);
        }
    }

    function _setValidator(address validator, bool isValid) internal {
        _validators[validator] = isValid;
    }

    function verificationStatusOf(
        uint256 tokenId
    ) external view returns (VerificationStatus) {
        return _smartNFTInfos[tokenId].status;
    }

    function isValidator(address validator) external view returns (bool) {
        return _validators[validator];
    }

    function smartNFTInfoOf(
        uint256 tokenId
    ) external view returns (SmartNFTInfo memory) {
        return _smartNFTInfos[tokenId];
    }

    function smartNFTTokenIdOf(
        address smartNFT
    ) external view returns (uint256) {
        return _smartNFTTokenIds[smartNFT];
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155) returns (bool) {
        return
            interfaceId == type(ISmartManager).interfaceId ||
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _beforeRegister() internal virtual {}

    function _afterRegister() internal virtual {}
}
