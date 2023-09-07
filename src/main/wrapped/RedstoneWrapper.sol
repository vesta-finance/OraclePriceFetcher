// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "./BaseWrapper.sol";
import "../interfaces/IRedstoneAdapter.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract RedstoneWrapper is BaseWrapper, OwnableUpgradeable {
    event OracleAdded(address indexed _token, address _externalOracle);

    struct OracleResponse {
        uint256 currentPrice;
        bool success;
    }

    struct Oracle {
        bytes32 code;
        address adapter;
        uint8 decimals;
    }

    mapping(address => Oracle) public oracles;
    mapping(address => SavedResponse) public savedResponses;

    function setUp() external initializer {
        __Ownable_init();
    }

    function addOracle(address _token, address _adapter, bytes32 _tokenCode, uint8 _decimals) external onlyOwner {
        require(_decimals != 0, "Invalid Decimals");

        oracles[_token] = Oracle(_tokenCode, _adapter, _decimals);

        OracleResponse memory response = _getResponses(_token);

        if (_isBadOracleResponse(response)) {
            revert ResponseFromOracleIsInvalid(_token, address(this));
        }

        savedResponses[_token].currentPrice = response.currentPrice;
        savedResponses[_token].lastPrice = response.currentPrice;
        savedResponses[_token].lastUpdate = block.timestamp;

        emit OracleAdded(_token, address(this));
    }

    function removeOracle(address _token) external onlyOwner {
        delete oracles[_token];
        delete savedResponses[_token];
    }

    function retriveSavedResponses(address _token) external override returns (SavedResponse memory savedResponse) {
        fetchPrice(_token);
        return savedResponses[_token];
    }

    function fetchPrice(address _token) public override {
        OracleResponse memory oracleResponse = _getResponses(_token);
        SavedResponse storage responses = savedResponses[_token];

        if (_isBadOracleResponse(oracleResponse)) return;

        responses.lastPrice = responses.currentPrice;
        responses.currentPrice = oracleResponse.currentPrice;
        responses.lastUpdate = block.timestamp;
    }

    function getLastPrice(address _token) external view override returns (uint256) {
        return savedResponses[_token].lastPrice;
    }

    function getCurrentPrice(address _token) external view override returns (uint256) {
        return savedResponses[_token].currentPrice;
    }

    function getExternalPrice(address _token) external view override returns (uint256) {
        OracleResponse memory oracleResponse = _getResponses(_token);
        return oracleResponse.currentPrice;
    }

    function _getResponses(address _token) internal view returns (OracleResponse memory response) {
        Oracle memory oracle = oracles[_token];
        if (oracle.adapter == address(0)) {
            revert TokenIsNotRegistered(_token);
        }

        uint8 decimals = oracle.decimals;
        uint256 currentPrice = IRedstoneAdapter(oracle.adapter).getValueForDataFeed(oracle.code);
        uint256 scaledPrice = scalePriceByDigits(currentPrice, decimals);

        response.currentPrice = scaledPrice;
        response.success = currentPrice != 0;

        return response;
    }

    function _isBadOracleResponse(OracleResponse memory _response) internal pure returns (bool) {
        return (!_response.success || _response.currentPrice <= 0);
    }
}
