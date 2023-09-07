// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "../interfaces/IPriceOracleV1.sol";
import "../interfaces/IOracleWrapper.sol";
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

    //Sunsetting Vesta VST oracle, migrating to Redstone
    function getPriceData() external view returns (uint256 _currentPrice, uint256 _lastPrice, uint256 _lastUpdate) {
        _currentPrice = IOracleWrapper(0x09E54b1baD677900Aa7d18e5ce65CB1Ba9d2f666).getExternalPrice(
            0x64343594Ab9b56e99087BfA6F2335Db24c2d1F17
        );

        //scaling down answer to contract's decimals value.
        _currentPrice = scalePriceByDigits(_currentPrice, 18);

        return (_currentPrice, _currentPrice, block.timestamp);
    }

    function scalePriceByDigits(uint256 _price, uint256 _answerDigits) internal view returns (uint256) {
        return _answerDigits < decimals
            ? _price * (10 ** (decimals - _answerDigits))
            : _price / (10 ** (_answerDigits - decimals));
    }
}
