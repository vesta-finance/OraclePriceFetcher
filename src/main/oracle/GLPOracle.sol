// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "../interfaces/IGLPManager.sol";
import "../interfaces/IGMXVault.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { IERC20Upgradeable as IERC20 } from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract GLPOracle is Initializable {
	uint8 public constant decimals = 18;
	IGLPManager public glpManager;
	IGMXVault public gmxVault;
	IERC20 public glp;

	function setUp(
		address _glp,
		address _glpManager,
		address _gmxVault
	) external initializer {
		glp = IERC20(_glp);
		glpManager = IGLPManager(_glpManager);
		gmxVault = IGMXVault(_gmxVault);
	}

	function getPrice() external view returns (uint256) {
		uint256 fee = gmxVault.mintBurnFeeBasisPoints() +
			gmxVault.taxBasisPoints();

		uint256 rawPrice = (glpManager.getAumInUsdg(false) * 1e18) /
			glp.totalSupply();

		return rawPrice - ((rawPrice * fee) / 10_000);
	}
}
