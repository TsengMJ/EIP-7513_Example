// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC20/IERC20.sol";
import "@smart-manager/interfaces/ISmartManager.sol";
import "./BaseSmartNFT.sol";

interface IPool {
    function getUserAccountData(
        address user
    )
        external
        view
        returns (
            uint256,
            uint256,
            uint256 avaliableBorrowsBase,
            uint256,
            uint256,
            uint256
        );

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;
}

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IPrice {
    function getAssetPrice(address asset) external view returns (uint256);
}

contract RevolvingLendingSmartNFT is BaseSmartNFT {
    address constant AAVE_ADDR = 0x48914C788295b5db23aF2b5F0B3BE775C4eA9440;
    address constant PRICE_ADDR = 0x4B7C7D2EbcDc1015D35F617596318C15d9d24e59;
    address constant ROUTER02_ADDR = 0x2f2f7197d19A13e8c72c1087dD29d555aBE76C5C;
    address constant USDC_ADDR = 0x2C9678042D52B97D27f2bD2947F7111d93F3dD0D;

    constructor(
        address manager_,
        uint256 tokenId_
    ) BaseSmartNFT(manager_, tokenId_) {}

    struct ExecuteParam {
        uint256 count; // Number of recurring loans
        uint256 amountIn; // The number of tokens entered by the user
        address to; // lending address
        address inputAsset; // Input asset address
        address outputAsset; // Output asset address
    }

    function execute(
        bytes memory data
    ) external payable override returns (bool) {
        require(validatePermission(), "invalid permission");

        ExecuteParam memory param;
        param = abi.decode(data, (ExecuteParam));

        uint256 outputAssetBalanceBefore = IERC20(param.outputAsset).balanceOf(
            address(this)
        );
        IERC20(param.inputAsset).transferFrom(
            msg.sender,
            address(this),
            param.amountIn
        );

        for (uint256 i = 0; i < param.count; i++) {
            if (i == 0) {
                IERC20(param.inputAsset).approve(ROUTER02_ADDR, param.amountIn);
                address[] memory path = new address[](2);
                path[0] = param.inputAsset;
                path[1] = param.outputAsset;
                IUniswapV2Router02(ROUTER02_ADDR).swapExactTokensForTokens(
                    param.amountIn,
                    0,
                    path,
                    address(this),
                    block.timestamp + 1000
                );
            } else {
                uint256 outputAssetBalanceCurrent = IERC20(param.outputAsset)
                    .balanceOf(address(this));
                uint256 outputAssetBalanceDiff = outputAssetBalanceCurrent -
                    outputAssetBalanceBefore;
                IERC20(param.outputAsset).approve(
                    AAVE_ADDR,
                    outputAssetBalanceDiff
                );
                IPool(AAVE_ADDR).supply(
                    param.outputAsset,
                    outputAssetBalanceDiff,
                    address(this),
                    0
                );

                uint256 borrowBase;
                (, , borrowBase, , , ) = IPool(AAVE_ADDR).getUserAccountData(
                    address(this)
                );
                require(borrowBase > 0, "NOT ENOUGH BORROW BASE");

                uint256 price = IPrice(PRICE_ADDR).getAssetPrice(USDC_ADDR);
                uint256 amount = (borrowBase * 8) / price / 10;
                require(amount > 0, "NOT ENOUGH BORROW");

                IPool(AAVE_ADDR).borrow(USDC_ADDR, amount, 2, 0, address(this));
                uint256 amountUSDC = amount;
                require(amountUSDC > 0, "NOT ENOUGH USDC");

                IERC20(USDC_ADDR).approve(ROUTER02_ADDR, amountUSDC);
                address[] memory path = new address[](2);
                path[0] = USDC_ADDR;
                path[1] = param.outputAsset;
                IUniswapV2Router02(ROUTER02_ADDR).swapExactTokensForTokens(
                    amountUSDC,
                    0,
                    path,
                    address(this),
                    block.timestamp + 1000
                );
            }
        }

        return true;
    }
}
