export interface IDeployConfig {
	isTestnet: boolean
	outputFile: string
	TX_CONFIRMATIONS: number
	chainlinkSEQFlag: string
	chainlinkFlagsContract: string
	adminAddress: string

	rentBTC: string
	gohm: string
	ethChainlink: IChainlinkOracle
	btcChainlink: IChainlinkOracle
	gohmChainlink: IChainlinkOracle

	dopex?: string
	dopexOracle?: ICustomOracle
}

export interface IChainlinkOracle {
	priceOracle: string
	indexOracle: string
}

export interface ICustomOracle {
	contract: string
	decimals: number
	currentPriceHex: string
	lastPriceHex: string
	lastUpdateHex: string
	decimalsHex: string
}
