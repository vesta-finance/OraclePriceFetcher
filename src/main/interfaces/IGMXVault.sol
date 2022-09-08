pragma solidity >=0.8.0;

interface IGMXVault {
	function taxBasisPoints() external view returns (uint256);

	function mintBurnFeeBasisPoints() external view returns (uint256);
}
