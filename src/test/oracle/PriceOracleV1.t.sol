// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.11;

import { BaseTest, console } from "../base/BaseTest.sol";
import "../../main/oracle/PriceOracleV1.sol";

contract PriceOracleV1Test is BaseTest {
	bytes private constant REVERT_INVALID_NODE = "VestaPriceOracleV1: invalid node address";
	bytes private constant REVERT_NOT_TRUSTED_NODE = "VestaPriceOracleV1: address is not trusted";

	PriceOracleV1 private underTest;

	address private owner;
	address private trustedNode;
	address private user;

	function setUp() public {
		vm.warp(10000);

		underTest = new PriceOracleV1();
		owner = accountsDb.PUBLIC_KEYS(0);
		trustedNode = accountsDb.PUBLIC_KEYS(1);
		user = accountsDb.PUBLIC_KEYS(2);

		vm.startPrank(owner);
		{
			// Set decimals of 1 for test purposes
			underTest.setUp(10, 11, 1);

			// Register a node
			underTest.registerTrustedNode(trustedNode);
		}
		vm.stopPrank();
	}

	function test_setUp_CallerIsOwner() public prankAs(user) {
		underTest = new PriceOracleV1();

		underTest.setUp(10, 11, 1);
		// Owner is set correctly
		assertEq(underTest.owner(), user);
	}

	function test_registerTrustedNode_GivenNotOwner_thenReverts() public prankAs(user) {
		// Only owner is able to register a valid node
		vm.expectRevert(REVERT_NOT_OWNER);
		underTest.registerTrustedNode(trustedNode);
	}

	function test_registerTrustedNode_GivenInvalidNode_thenReverts() public prankAs(owner) {
		// Invalid node can not be registered
		vm.expectRevert(REVERT_INVALID_NODE);
		underTest.registerTrustedNode(address(0));
	}

	function test_setUp_GivenValidNode_thenRegisterTrustedNodeAndCallerIsOwner() public prankAs(user) {
		underTest = new PriceOracleV1();

		underTest.setUp(10, 11, 1);
		// Owner is able to register a valid node
		underTest.registerTrustedNode(trustedNode);
	}

	function test_update_GivenNotTrustedNode_thenReverts() public {
		vm.prank(owner);
		underTest.unregisterTrustedNode(trustedNode);

		// Already unregisterd, so not trusted now
		vm.startPrank(trustedNode);
		{
			// Update attempt from untrusted node, then reverts
			vm.expectRevert(REVERT_NOT_TRUSTED_NODE);
			underTest.update(12);
		}
		vm.stopPrank();
	}

	function test_update_GivenTrustedNode_thenUpdatesCorrectly() public {
		vm.prank(owner);
		underTest.registerTrustedNode(trustedNode);

		(uint256 _currentPrice, , uint256 _round, uint256 _lastUpdate) = underTest.getPriceData();

		// Trusted Node is able to update price
		vm.prank(trustedNode);
		underTest.update(12);

		(uint256 currentPrice, uint256 lastPrice, uint256 round, uint256 lastUpdate) = underTest.getPriceData();

		assertEq(currentPrice, 12);
		assertEq(_currentPrice, lastPrice);
		assertEq(_round + 1, round);
		assertTrue(_lastUpdate <= lastUpdate);
	}
}
