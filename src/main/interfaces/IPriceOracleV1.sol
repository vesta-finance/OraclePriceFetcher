// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

interface IPriceOracleV1 {
	function setDecimals(uint8 _decimals) external;

	function registerTrustedNode(address _node) external;

	function unregisterTrustedNode(address _node) external;

	function update(uint256 newPrice) external;

	function getPriceData()
		external
		view
		returns (
			uint256 _currentPrice,
			uint256 _lastPrice,
			uint256 _round,
			uint256 _lastUpdate
		);
}
