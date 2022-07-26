pragma solidity ^0.8.13;

import "../../main/oracle/GLPOracle.sol";
import "../../main/interfaces/IGLPManager.sol";
import "../mock/MockERC20.sol";
import { BaseTest, console } from "../base/BaseTest.t.sol";

contract GLPOracleTest is BaseTest {
	GLPOracle private underTest;

	function setUp() public {
		underTest = new GLPOracle();
		underTest.setUp(address(0x1), address(0x2));
	}

	function test_setUp_thenStorageValueAreCorrect() external {
		underTest = new GLPOracle();
		underTest.setUp(address(0x1), address(0x2));

		assertEq(address(underTest.glp()), address(0x1));
		assertEq(address(underTest.glpManager()), address(0x2));
		assertEq(underTest.decimals(), 18);
	}

	function test_setUp_calledTwice_thenReverts() external {
		vm.expectRevert(REVERT_ALREADY_INITIALIZED);
		underTest.setUp(address(0), address(0));
	}

	function test_getPrice_thenReturnsInUSD() public {
		uint256 mockMinimum = 15_000 ether;
		uint256 mockMaximum = 45_000 ether;
		uint256 mockSupply = 100_500 ether;

		vm.mockCall(
			address(0x2),
			abi.encodeWithSignature("getAumInUsdg(bool)", false),
			abi.encode(mockMinimum)
		);
		vm.mockCall(
			address(0x2),
			abi.encodeWithSignature("getAumInUsdg(bool)", true),
			abi.encode(mockMaximum)
		);
		vm.mockCall(
			address(0x1),
			abi.encodeWithSignature("totalSupply()"),
			abi.encode(mockSupply)
		);

		assertEq(
			underTest.getPrice(),
			(((mockMinimum + mockMaximum) / 2) * 1e18) / mockSupply
		);
	}
}
