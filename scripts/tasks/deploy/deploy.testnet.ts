import { IDeployConfig } from "../../config/DeployConfig"
import { Deployer } from "./Deployer"
import { HardhatRuntimeEnvironment } from "hardhat/types/runtime"
import { DeploymentHelper } from "../../utils/DeploymentHelper"
import { constants } from "ethers"

const config: IDeployConfig = {
	TX_CONFIRMATIONS: 1,
	FirstDeployment: {
		arbitrumTestnet: {
			isTestnet: true,

			chainlinkSEQFlag: "0xa438451D6458044c3c8CD2f6f31c91ac882A6d91",
			chainlinkFlagsContract: "0x491B1dDA0A8fa069bbC1125133A975BF4e85a91b",
			adminAddress: "0x87209dc4B76b14B67BC5E5e5c0737E7d002a219c",
			rentBTC: "0x2DEEaEFA1f182bD03763851cee7618242820322f",
			gohm: "0x64f402E37C5F105bfaa4F8629520c91507Cc84f8",
			ethChainlink: {
				priceOracle: "0x5f0423B1a6935dc5596e7A24d98532b67A0AeFd8",
				indexOracle: constants.AddressZero,
			},
			btcChainlink: {
				priceOracle: "0x0c9973e7a27d00e656B9f153348dA46CaD70d03d",
				indexOracle: constants.AddressZero,
			},
			gohmChainlink: {
				priceOracle: constants.AddressZero,
				indexOracle: constants.AddressZero,
			},

			twap: {
				weth: "0xB47e6A5f8b33b3F17603C83a0535A9dcD7E32681",
				chainlinkEth: "0x5f0423B1a6935dc5596e7A24d98532b67A0AeFd8",
				chainlingFlagSEQ: "0xa438451D6458044c3c8CD2f6f31c91ac882A6d91",
				chainlinkFlagsContract:
					"0x491B1dDA0A8fa069bbC1125133A975BF4e85a91b",
			},
		},
	},
}

export async function execute(hre: HardhatRuntimeEnvironment) {
	const helper = new DeploymentHelper(config, hre)

	const mockGohmPriceOracle = await helper.deployContractByName(
		"MockOracle",
		"gohmOracle"
	)
	await mockGohmPriceOracle.setUp("2735860000000", "2735860000000", 9)

	config.FirstDeployment![hre.network.name]!.gohmChainlink = {
		priceOracle: mockGohmPriceOracle.address,
		indexOracle: constants.AddressZero,
	}

	await new Deployer(config, hre).run()
}
