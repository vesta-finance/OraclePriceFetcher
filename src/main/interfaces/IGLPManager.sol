pragma solidity >=0.8.0;

interface IGLPManager {
	function getAumInUsdg(bool maximise) external view returns (uint256);
}
