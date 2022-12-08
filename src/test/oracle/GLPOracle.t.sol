pragma solidity ^0.8.13;

import "../../main/oracle/GLPOracle.sol";
import "../../main/interfaces/IGMXVault.sol";
import "../../main/interfaces/IGLPManager.sol";
import "../mock/MockERC20.sol";
import { BaseTest, console } from "../base/BaseTest.t.sol";

contract GLPOracleTest is BaseTest {
	GLPOracle private underTest;
	address private glp = address(0x1);
	address private glpManager = address(0x2);
	address private vault = address(0x3);
	address private owner = address(0x4);

	function setUp() public {
		underTest = new GLPOracle();
		underTest.setUp(glp, glpManager, vault);
		underTest.initOwnership(owner);
	}

	function test_setUp_thenStorageValueAreCorrect() external {
		underTest = new GLPOracle();
		underTest.setUp(glp, glpManager, vault);

		assertEq(address(underTest.glp()), glp);
		assertEq(address(underTest.glpManager()), glpManager);
		assertEq(address(underTest.gmxVault()), vault);
		assertEq(underTest.decimals(), 18);
	}

	function test_setUp_calledTwice_thenReverts() external {
		vm.expectRevert(REVERT_ALREADY_INITIALIZED);
		underTest.setUp(address(0), address(0), address(0));
	}

	function test_initOwnership_whenOwnerIsNotSet_thenAddressIsOwner()
		external
	{
		underTest = new GLPOracle();
		underTest.setUp(glp, glpManager, vault);

		underTest.initOwnership(owner);
		assertEq(underTest.owner(), owner);
	}

	function test_initOwnership_whenAlreadyInited_thenReverts() external {
		underTest = new GLPOracle();
		underTest.setUp(glp, glpManager, vault);

		underTest.initOwnership(owner);

		vm.expectRevert("Already has an owner");
		underTest.initOwnership(owner);
	}

	function test_setGLPManager_asUser_thenReverts() external {
		vm.expectRevert("Owner only");
		underTest.setGLPManager(address(0x5));
	}

	function test_setGLPManager_asOwner_thenUpdatesGLPManager()
		external
		prankAs(owner)
	{
		underTest.setGLPManager(address(0x51));
		assertEq(address(underTest.glpManager()), address(0x51));
	}

	function test_getPrice_thenReturnsInUSD() public {
		uint256 mockMinimum = 15_000 ether;
		uint256 mockSupply = 100_500 ether;

		vm.mockCall(
			glpManager,
			abi.encodeWithSelector(IGLPManager.getAumInUsdg.selector, false),
			abi.encode(mockMinimum)
		);

		vm.mockCall(
			glp,
			abi.encodeWithSignature("totalSupply()"),
			abi.encode(mockSupply)
		);

		vm.mockCall(
			vault,
			abi.encodeWithSelector(IGMXVault.mintBurnFeeBasisPoints.selector),
			abi.encode(30)
		);

		vm.mockCall(
			vault,
			abi.encodeWithSelector(IGMXVault.taxBasisPoints.selector),
			abi.encode(30)
		);

		mockMinimum = (mockMinimum * 1e18) / mockSupply;
		mockMinimum -= (mockMinimum * 60) / 10_000;

		assertEq(underTest.getPrice(), mockMinimum);
	}
}

