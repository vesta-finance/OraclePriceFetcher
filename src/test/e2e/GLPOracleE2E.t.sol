pragma solidity ^0.8.13;

import "../../main/oracle/GLPOracle.sol";
import "../../main/interfaces/IGLPManager.sol";
import "../../main/interfaces/IGMXVault.sol";
import "../mock/MockERC20.sol";
import "../base/BaseTest.t.sol";

contract GLPOracleE2ETest is BaseTest {
	IGLPManager private constant glpManager =
		IGLPManager(0x3963FfC9dff443c2A94f21b129D429891E32ec18);
	MockERC20 private constant glp =
		MockERC20(0x4277f8F2c384827B5273592FF7CeBd9f2C1ac258);
	IGMXVault private constant vault =
		IGMXVault(0x489ee077994B6658eAfA855C308275EAd8097C4A);

	GLPOracle private underTest;

	function setUp() public {
		underTest = new GLPOracle();
		underTest.setUp(address(glp), address(glpManager), address(vault));
	}

	function test_getPrice_thenReturnsInUSD() public {
		uint256 fee = vault.mintBurnFeeBasisPoints() + vault.taxBasisPoints();
		uint256 rawPrice = (glpManager.getAumInUsdg(false) * 1e18) /
			glp.totalSupply();
		uint256 expectedPrice = rawPrice - (rawPrice * fee) / 10_000;

		assertEq(underTest.getPrice(), expectedPrice);
	}
}

