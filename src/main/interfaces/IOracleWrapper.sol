// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.11;

interface IOracleWrapper {
	struct SavedResponse {
		uint256 currentPrice;
		uint256 lastPrice;
		uint256 lastUpdate;
	}

	error TokenIsNotRegistered(address _token);
	error ResponseFromOracleIsInvalid(address _token, address _oracle);

	/// @notice fetchPrice update the contract's storage price of a specific token.
	/// @dev This is mainly accessible for testing when you add a new oracle. retriveSavedResponses is also fetching the price
	/// @param _token the token you want to update.
	function fetchPrice(address _token) external;

	/// @notice retriveSavedResponses gets external oracles price and update the storage value.
	/// @dev Sad typo.
	/// @param _token the token you want to price. Needs to be supported by the wrapper.
	/// @return currentResponse The current price, the last price and the last update.
	function retriveSavedResponses(address _token) external returns (SavedResponse memory currentResponse);

	/// @notice getLastPrice gets the last price saved in the contract's storage
	/// @param _token the token you want to price. Needs to be supported by the wrapper
	/// @return the price in 1e18 format
	function getLastPrice(address _token) external view returns (uint256);

	/// @notice getCurrentPrice gets the current price saved in the contract's storage
	/// @param _token the token you want to price. Needs to be supported by the wrapper
	/// @return the price in 1e18 format
	function getCurrentPrice(address _token) external view returns (uint256);

	/// @notice getExternalPrice gets the price from the external oracle directly
	/// @dev This is for the front-end and have no secruity. So do not use it as information source in a smart contract
	/// @param _token the token you want to price. Needs to be supported by the wrapper
	/// @return the price in 1e18 format
	function getExternalPrice(address _token) external view returns (uint256);
}
