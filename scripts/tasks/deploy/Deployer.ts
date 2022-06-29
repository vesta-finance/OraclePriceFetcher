import { IDeployConfig } from "../../config/DeployConfig"
import { DeploymentHelper } from "../../utils/DeploymentHelper"
import { HardhatRuntimeEnvironment } from "hardhat/types/runtime"
import { HardhatEthersHelpers } from "@nomiclabs/hardhat-ethers/types"
import { Contract, Signer } from "ethers"
import { ZERO_ADDRESS } from "../../Deployer"
import { FirstDeployment } from "../../config/contractConfigs/FirstDeploymentConfig"

export class Deployer {
	config: IDeployConfig
	chainConfig?: FirstDeployment
	helper: DeploymentHelper
	ethers: HardhatEthersHelpers
	hre: HardhatRuntimeEnvironment

	deployer?: Signer

	verificator?: Contract
	priceFeedV2?: Contract
	customOracle?: Contract
	chainlinkOracle?: Contract
	twapOracle?: Contract

	constructor(config: IDeployConfig, hre: HardhatRuntimeEnvironment) {
		this.hre = hre
		this.ethers = hre.ethers
		this.config = config
		this.helper = new DeploymentHelper(config, hre)
	}

	async run() {
		this.deployer = (await this.ethers.getSigners())[0]
		this.chainConfig = this.config.FirstDeployment![this.hre.network.name]

		if (this.chainConfig !== undefined) {
			throw `ChainConfig isn't configured for ${this.hre.network.name}`
		}

		this.verificator = await this.helper.deployUpgradeableContractWithName(
			"OracleVerificationV1",
			"OracleVerificationV1"
		)

		this.priceFeedV2 = await this.helper.deployUpgradeableContractWithName(
			"PriceFeedV2",
			"PriceFeedV2",
			"setUp",
			this.verificator.address
		)

		this.customOracle =
			await this.helper.deployUpgradeableContractWithName(
				"CustomOracleWrapper",
				"CustomOracleWrapper",
				"setUp"
			)

		this.chainlinkOracle =
			await this.helper.deployUpgradeableContractWithName(
				"ChainlinkWrapper",
				"ChainlinkWrapper",
				"setUp",
				this.chainConfig!.chainlinkSEQFlag,
				this.chainConfig!.chainlinkFlagsContract
			)

		this.twapOracle = await this.helper.deployContractByName(
			"TwapOracleWrapper",
			"TwapOracleWrapper",
			this.chainConfig!.twap?.weth,
			this.chainConfig!.twap?.chainlinkEth,
			this.chainConfig!.twap?.chainlingFlagSEQ,
			this.chainConfig!.twap?.chainlinkFlagsContract
		)

		await this.configOracles()
		await this.configPriceFeedV2()
		await this.transferOwnership()
	}

	async configOracles() {
		console.log("configOracles()")

		if (this.chainConfig!.isTestnet) {
			//giving wrong decimals for testing -- it should get the decimals of the contract
			await this.helper.sendAndWaitForTransaction(
				this.customOracle?.addOracle(
					this.chainConfig!.gohm,
					this.chainConfig!.gohmChainlink.priceOracle,
					18,
					"0x9d1b464a",
					"0x053f14da",
					"0x",
					"0x313ce567"
				)
			)
		} else {
			await this.helper.sendAndWaitForTransaction(
				this.chainlinkOracle?.addOracle(
					this.chainConfig!.gohm,
					this.chainConfig!.gohmChainlink.priceOracle,
					this.chainConfig!.gohmChainlink.indexOracle
				)
			)
		}

		await this.helper.sendAndWaitForTransaction(
			this.chainlinkOracle?.addOracle(
				ZERO_ADDRESS,
				this.chainConfig!.ethChainlink.priceOracle,
				ZERO_ADDRESS
			)
		)

		await this.helper.sendAndWaitForTransaction(
			this.chainlinkOracle?.addOracle(
				this.chainConfig!.rentBTC,
				this.chainConfig!.btcChainlink.priceOracle,
				ZERO_ADDRESS
			)
		)

		if (this.chainConfig!.dopex !== undefined) {
			console.log("Dopex")
			await this.helper.sendAndWaitForTransaction(
				this.customOracle?.addOracle(
					this.chainConfig!.dopex,
					this.chainConfig!.dopexOracle?.contract,
					this.chainConfig!.dopexOracle?.decimals,
					this.chainConfig!.dopexOracle?.currentPriceHex,
					this.chainConfig!.dopexOracle?.lastPriceHex,
					this.chainConfig!.dopexOracle?.lastUpdateHex,
					this.chainConfig!.dopexOracle?.decimalsHex
				)
			)
		}

		if (this.chainConfig!.gmx !== undefined) {
			await this.helper.sendAndWaitForTransaction(
				await this.twapOracle?.addOracle(
					this.chainConfig!.gmx?.token,
					this.chainConfig!.gmx?.pool
				)
			)
		}
	}

	async configPriceFeedV2() {
		console.log("configPriceFeedV2()")

		await this.helper.sendAndWaitForTransaction(
			this.priceFeedV2?.addOracle(
				ZERO_ADDRESS,
				this.chainlinkOracle?.address,
				ZERO_ADDRESS
			)
		)
		await this.helper.sendAndWaitForTransaction(
			this.priceFeedV2?.addOracle(
				this.chainConfig!.gohm,
				this.chainlinkOracle?.address,
				ZERO_ADDRESS
			)
		)
		await this.helper.sendAndWaitForTransaction(
			this.priceFeedV2?.addOracle(
				this.chainConfig!.rentBTC,
				this.chainlinkOracle?.address,
				ZERO_ADDRESS
			)
		)
	}

	async transferOwnership() {
		if ((await this.priceFeedV2?.owner()) == this.deployer?.getAddress()) {
			await this.helper.sendAndWaitForTransaction(
				this.priceFeedV2?.transferOwnership(this.chainConfig!.adminAddress)
			)
		}

		if (
			(await this.customOracle?.owner()) == this.deployer?.getAddress()
		) {
			await this.helper.sendAndWaitForTransaction(
				this.customOracle?.transferOwnership(
					this.chainConfig!.adminAddress
				)
			)
		}

		if (
			(await this.chainlinkOracle?.owner()) == this.deployer?.getAddress()
		) {
			await this.helper.sendAndWaitForTransaction(
				this.chainlinkOracle?.transferOwnership(
					this.chainConfig!.adminAddress
				)
			)
		}

		this.hre.upgrades.admin.transferProxyAdminOwnership(
			this.chainConfig!.adminAddress
		)
	}
}
