import { SupportedChain } from "./NetworkConfig"
import { FirstDeployment } from "./contractConfigs/FirstDeploymentConfig"
import { VstOracleConfig } from "./contractConfigs/VstOracleConfig"
import { GLPOracleConfig } from "./contractConfigs/GLPOracleConfig"

export interface IDeployConfig {
	TX_CONFIRMATIONS: number
	FirstDeployment?: CrossChainFirstDeployment
	VstDeployment?: VstOracleConfig
	GLPOracleConfig?: GLPOracleConfig
}

export type CrossChainFirstDeployment = {
	[key in SupportedChain | string]?: FirstDeployment
}
