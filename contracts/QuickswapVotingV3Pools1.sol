// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import "./interfaces/INonfungiblePositionManager.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IAlgebraPoolState.sol";
import "./interfaces/IFarmingCenter.sol";
import "./libraries/PoolAddress.sol";
import "./libraries/TickMath.sol";
import "./libraries/LiquidityAmounts.sol";



// Factory- 0x411b0fAcC3489691f28ad58c47006AF5E3Ab3A28
// Router- 0xf5b509bB0909a69B1c207E495f687a596C168E12

contract QuickswapVotingV3Pools1 {

    IERC20 constant public QUICK = IERC20(0xB5C064F955D8e7F38fE0460C556a72987494eE17);
    INonfungiblePositionManager constant public nonfungiblePositionManager = INonfungiblePositionManager(0x8eF88E4c7CfbbaC1C163f7eddd4B578792201de6);    
    address constant POOL_DEPLOYER = 0x2D98E2FA9da15aa6dC9581AB097Ced7af697CB92;
    IFarmingCenter constant FARMING = IFarmingCenter(0x7F281A8cdF66eF5e9db8434Ec6D97acc1bc01E78);

    function balanceOf(address _owner) external view returns (uint256 balance_) {        
        uint256 positionsBalance = nonfungiblePositionManager.balanceOf(_owner);
        for(uint256 i; i < positionsBalance; i++) {
            uint256 tokenId = nonfungiblePositionManager.tokenOfOwnerByIndex(_owner, i);
            balance_ += QUICKFromPosition(tokenId);
        }
        positionsBalance = FARMING.balanceOf(_owner);
        for(uint256 i; i < positionsBalance; i++) {
            (,,uint256 tokenId) = FARMING.l2Nfts(FARMING.tokenOfOwnerByIndex(_owner, i));
            balance_ += QUICKFromPosition(tokenId);
        }

    }

    function QUICKFromPosition(uint256 tokenId) internal view returns (uint256 quickAmount_) {
        (
            ,
            ,
            address token0,
            address token1,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            ,
            ,
            ,                
        ) = nonfungiblePositionManager.positions(tokenId);
        if(token0 != address(QUICK) && token1 != address(QUICK)) {
            return 0;
        }                        
        address pool = poolAddress(token0, token1);
        (uint160 currentPrice,,,,,,) = IAlgebraPoolState(pool).globalState();

        (uint256 amount0, uint256 amount1) = LiquidityAmounts.getAmountsForLiquidity(
            currentPrice, 
            TickMath.getSqrtRatioAtTick(tickLower),
            TickMath.getSqrtRatioAtTick(tickUpper),
            liquidity
        );
        if(token0 == address(QUICK)) {
            quickAmount_ += amount0;
        }
        else {
            quickAmount_ += amount1;
        }
    }

    function poolAddress(address tokenA, address tokenB) internal pure returns (address) {
        return PoolAddress.computeAddress(POOL_DEPLOYER, PoolAddress.getPoolKey(tokenA, tokenB));
    }


}