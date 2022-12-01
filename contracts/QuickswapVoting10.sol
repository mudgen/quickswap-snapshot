//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

struct StakingRewardsInfo {
    address stakingRewards;
    uint rewardAmount;
    uint duration;
}

interface IStakingRewardsFactory {
  function rewardTokens(uint256 _index) view external returns (address);
  function stakingRewardsInfoByRewardToken(address _rewardToken) view external returns(StakingRewardsInfo memory);
}


IStakingRewardsFactory constant NEWQUICKSRF = IStakingRewardsFactory(0xEDA776E7e1111BE5E82F9148B2deF870f99c1908);

contract QuickswapVoting10 { 

  function balanceOf(address _owner) external view returns (uint256 balance_) {
    for(uint256 i; true; i++) {      
      (bool success, bytes memory result) = address(NEWQUICKSRF).staticcall(abi.encodeWithSelector(IStakingRewardsFactory.rewardTokens.selector, i));
      if(success == true) {
        address rewardTokenAddress = abi.decode(result, (address));
        StakingRewardsInfo memory stakingRewardsInfo = NEWQUICKSRF.stakingRewardsInfoByRewardToken(rewardTokenAddress);
        balance_ += IERC20(stakingRewardsInfo.stakingRewards).balanceOf(_owner);        
      }
      else {
        break;
      }      
    }    
  }
}