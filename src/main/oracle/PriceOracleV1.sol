// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "../interfaces/IPriceOracleV1.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract PriceOracleV1 is IPriceOracleV1, OwnableUpgradeable {
	string public ORACLE_NAME;

	uint256 public currentPrice;
	uint256 public lastPrice;
	uint256 public lastUpdate;
	uint8 public decimals;

	mapping(address => bool) private trusted;

	modifier isTrusted() {
		if (!trusted[msg.sender]) revert AddressNotTrusted();
		_;
	}

	modifier checkNonZeroAddress(address _addr) {
		if (_addr == address(0)) revert ZeroAddress();
		_;
	}

	function setUp(string memory _oracleName, uint8 _decimals) external initializer {
		__Ownable_init();

		ORACLE_NAME = _oracleName;
		decimals = _decimals;
	}

	function setDecimals(uint8 _decimals) external onlyOwner {
		decimals = _decimals;
	}

	function registerTrustedNode(address _node) external checkNonZeroAddress(_node) onlyOwner {
		trusted[_node] = true;
	}

	function unregisterTrustedNode(address _node) external checkNonZeroAddress(_node) onlyOwner {
		trusted[_node] = false;
	}

	function IsTrustedNode(address _node) external view returns (bool) {
		return trusted[_node];
	}

	function update(uint256 newPrice) external isTrusted {
		lastPrice = currentPrice;
		currentPrice = newPrice;
		lastUpdate = block.timestamp;
	}

	function getPriceData()
		external
		view
		returns (
			uint256 _currentPrice,
			uint256 _lastPrice,
			uint256 _lastUpdate
		)
	{
		return (currentPrice, lastPrice, lastUpdate);
	}
}
