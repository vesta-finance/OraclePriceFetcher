pragma solidity ^0.8.13;

import "../../main/oracle/GLPOracle.sol";
import "../../main/interfaces/IGLPManager.sol";
import "../mock/MockERC20.sol";
import "../base/BaseTest.t.sol";

contract GLPOracleE2ETest is BaseTest {
	IGLPManager private constant glpManager =
		IGLPManager(0x321F653eED006AD1C29D174e17d96351BDe22649);
	MockERC20 private constant glp =
		MockERC20(0x4277f8F2c384827B5273592FF7CeBd9f2C1ac258);

	GLPOracle private underTest;

	function setUp() public {
		underTest = new GLPOracle();
		underTest.setUp(address(glp), address(glpManager));
	}

	function test_getPrice_thenReturnsInUSD() public {
		uint256 expectedPrice = (glpManager.getAumInUsdg(false) * 1e18) /
			glp.totalSupply();

		assertEq(underTest.getPrice(), expectedPrice);
	}
}
