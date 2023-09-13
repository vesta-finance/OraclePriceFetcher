// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

interface IRedstoneAdapter {
    function getValueForDataFeed(bytes32 _tokenCode) external view returns (uint256);
}
