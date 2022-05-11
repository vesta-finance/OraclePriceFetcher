// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

interface IPriceFeedV2 {
	event OracleAdded(address indexed _token, address _primaryWrappedOracle, address _secondaryWrappedOracle);
	event OracleRemoved(address indexed _token);
	event AccessChanged(address indexed _token, bool _hasAccess);
	event OracleVerificationChanged(address indexed _newVerificator);
	event TokenPriceUpdated(address indexed _token, uint256 _price);

	struct Oracle {
		address primaryWrapper;
		address secondaryWrapper;
	}

	/// @notice fetchPrice gets external oracles price and update the storage value.
	/// @param _token the token you want to price. Needs to be supported by the wrapper.
	/// @return Return the correct price in 1e18 based on the verifaction contract.
	function fetchPrice(address _token) external returns (uint256);

	/// @notice register oracles for a new token
	/// @param _primaryOracle the main oracle we want to fetch the price from.
	/// @param _secondaryOracle the fallback oracle if the main is having any issue @Nullable.
	function addOracle(
		address _token,
		address _primaryOracle,
		address _secondaryOracle
	) external;

	/// @notice getExternalPrice gets external oracles price and update the storage value.
	/// @param _token the token you want to price. Needs to be supported by the wrapper.
	/// @return The current price reflected on the external oracle in 1e18 format.
	function getExternalPrice(address _token) external view returns (uint256);
}
