import { SupportedChain } from "./NetworkConfig"
import { FirstDeployment } from "./contractConfigs/FirstDeploymentConfig"
import { VstOracleConfig } from "./contractConfigs/VstOracleConfig"

export interface IDeployConfig {
	TX_CONFIRMATIONS: number
	FirstDeployment?: CrossChainFirstDeployment
	VstDeployment?: VstOracleConfig
}

export type CrossChainFirstDeployment = {
	[key in SupportedChain | string]?: FirstDeployment
}
