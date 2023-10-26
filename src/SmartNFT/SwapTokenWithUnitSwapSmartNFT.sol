// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC20/IERC20.sol";
import "@smart-manager/interfaces/ISmartManager.sol";
import "./interfaces/ISmartNFT.sol";
import "./BaseSmartNFT.sol";

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

contract SwapTokenWithUnitSwapSmartNFT is BaseSmartNFT {
    address public constant ROUTER02_ADDR =
        0x2f2f7197d19A13e8c72c1087dD29d555aBE76C5C;

    struct ExecuteParam {
        uint256 amountIn; // The number of tokens entered by the user
        address to; // Collection address
        address[] path; // [WBTC, USDT] -> WBTC to USDT
        uint256 deadline; // Collection deadline, unit seconds
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

        IERC20(param.path[0]).transferFrom(
            msg.sender,
            address(this),
            param.amountIn
        );
        IERC20(param.path[0]).approve(ROUTER02_ADDR, param.amountIn);
        uint256[] memory amounts = IUniswapV2Router02(ROUTER02_ADDR)
            .swapExactTokensForTokens(
                param.amountIn,
                0,
                param.path,
                param.to,
                param.deadline
            );

        return true;
    }
}
