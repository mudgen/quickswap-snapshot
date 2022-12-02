
// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

interface IFarmingCenter {

     /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);


    function l2Nfts(uint256)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            uint256 tokenId
        );

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);

}