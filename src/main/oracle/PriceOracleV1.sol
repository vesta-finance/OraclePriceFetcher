// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "../interfaces/IPriceOracleV1.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @dev Oracle contract for fetching a certain token price
 * Centralization issue still exists when adopting this contract for global uses
 * For special uses of supporting built-in protocols only
 */
contract PriceOracleV1 is IPriceOracleV1, OwnableUpgradeable {
	uint256 public currentPrice;
	uint256 public lastPrice;

	uint256 public round;
	uint256 public lastUpdate;

	mapping(address => bool) trusted;

	uint8 public decimals;

	error AddressNotTrusted();
	error ZeroAddress();

	modifier hasTrusted() {
		if (!trusted[msg.sender]) revert AddressNotTrusted();
		_;
	}

	modifier checkNonZeroAddress(address _addr) {
		if (_addr == address(0)) revert ZeroAddress();
		_;
	}

	function setUp(
		uint256 current,
		uint256 last,
		uint8 dec
	) external initializer {
		decimals = dec;

		currentPrice = current;
		lastPrice = last;

		round = 1;
		lastUpdate = block.timestamp;

		__Ownable_init();
	}

	function setDecimals(uint8 _decimals) external onlyOwner {
		decimals = _decimals;
	}

	/**
	 * @dev register address as a trusted Node
	 * Trusted node has permission to update price data
	 */
	function registerTrustedNode(address _node) external checkNonZeroAddress(_node) onlyOwner {
		trusted[_node] = true;
	}

	/**
	 * @dev remove address from tursted list
	 */
	function unregisterTrustedNode(address _node) external checkNonZeroAddress(_node) onlyOwner {
		trusted[_node] = false;
	}

	/**
	 * @dev update price data
	 * This function is supposed to be called by trusted node only
	 */
	function update(uint256 newPrice) external hasTrusted {
		lastPrice = currentPrice;
		currentPrice = newPrice;

		round++;
		lastUpdate = block.timestamp;
	}

	/**
	 * @dev returns current price data including price, round & time of last update
	 */
	function getPriceData()
		external
		view
		returns (
			uint256 _currentPrice,
			uint256 _lastPrice,
			uint256 _round,
			uint256 _lastUpdate
		)
	{
		return (currentPrice, lastPrice, round, lastUpdate);
	}
}
