export interface IDeployConfig {
	isTestnet?: boolean
	outputFile: string
	outputTxFile: string
	TX_CONFIRMATIONS: number
	chainlinkSEQFlag: string
	chainlinkFlagsContract: string
	adminAddress: string

	rentBTC: string
	gohm: string
	ethChainlink: IChainlinkOracle
	btcChainlink: IChainlinkOracle
	gohmChainlink: IChainlinkOracle
}

export interface IChainlinkOracle {
	priceOracle: string
	indexOracle: string
}
