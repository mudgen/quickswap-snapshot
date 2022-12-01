// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import "./interfaces/INonfungiblePositionManager.sol";
import "./interfaces/IAlgebraFactory.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IAlgebraPoolState.sol";
import "./libraries/PoolAddress.sol";
import "./libraries/TickMath.sol";
import "./libraries/LiquidityAmounts.sol";


// Factory- 0x411b0fAcC3489691f28ad58c47006AF5E3Ab3A28
// Router- 0xf5b509bB0909a69B1c207E495f687a596C168E12

contract QuickswapVotingV3Pools1 {

    IERC20 constant public QUICK = IERC20(0xB5C064F955D8e7F38fE0460C556a72987494eE17);
    INonfungiblePositionManager constant public nonfungiblePositionManager = INonfungiblePositionManager(0x8eF88E4c7CfbbaC1C163f7eddd4B578792201de6);
    IAlgebraFactory constant public factory = IAlgebraFactory(0x411b0fAcC3489691f28ad58c47006AF5E3Ab3A28);

    function balanceOf(address _owner) external view returns (uint256 balance_) {        
        uint256 positionsBalance = nonfungiblePositionManager.balanceOf(_owner);
        for(uint256 i; i < positionsBalance; i++) {
            uint256 tokenId = nonfungiblePositionManager.tokenOfOwnerByIndex(_owner, i);
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
            if(token0 != QUICK && token1 != QUICK) {
                continue;
            }                        
            address pool = poolAddress(token0, token1);
            (uint160 currentPrice,,,,,,) = IAlgebraPoolState(pool).globalState();

            (uint256 amount0, uint256 amount1) = LiquidityAmounts.getAmountsForLiquidity(
                currentPrice, 
                TickMath.getSqrtRatioAtTick(tickLower),
                TickMath.getSqrtRatioAtTick(tickUpper),
                liquidity
            );
            if(token0 == QUICK) {
                balance_ += amount0;
            }
            else {
                balance_ += amount1;
            }
        }
    }

    function poolAddress(address tokenA, address tokenB) internal pure returns (address) {
        return PoolAddress.computeAddress(address(factory), PoolAddress.getPoolKey(tokenA, tokenB));
    }


}