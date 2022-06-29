import { HardhatRuntimeEnvironment } from "hardhat/types/runtime"

import { addColor, colorLog, Colors } from "../utils/ColorConsole"
import readline from "readline-sync"
import { IDeployConfig } from "../config/DeployConfig"
import { DeploymentHelper } from "../utils/DeploymentHelper"

export default async function deployVST(
	params: any,
	hre: HardhatRuntimeEnvironment
): Promise<void> {
	const deploySettings: IDeployConfig = {
		TX_CONFIRMATIONS: 1,
		VstDeployment: {
			oracleName: "VST Oracle",
			trustedNode: "N/A",
			admin: "N/A",
		},
	}

	colorLog(
		Colors.yellow,
		`\nExecuting Deploy | Network: ${hre.network.name} | --env: ${params.env}\n`
	)
	switch (params.env.toLowerCase()) {
		case "mainnet":
			validUserIntention()
			deploySettings.VstDeployment!.trustedNode =
				"0xf42439c99E29f2A145E5eBD76186700e9aA52908"
			deploySettings.VstDeployment!.admin =
				"0x4A4651B31d747D1DdbDDADCF1b1E24a5f6dcc7b0"
			break
		case "testnet":
			deploySettings.VstDeployment!.trustedNode =
				"0x87209dc4B76b14B67BC5E5e5c0737E7d002a219c"

			deploySettings.VstDeployment!.admin =
				"0x87209dc4B76b14B67BC5E5e5c0737E7d002a219c"
			break
		default:
			throw "unsupported chain"
	}

	await deployContract(deploySettings, hre)
}

async function validUserIntention() {
	var userinput: string = "0"

	userinput = readline.question(
		addColor(
			Colors.yellow,
			`\nYou are about to deploy on the mainnet, is it fine? [y/N]\n`
		)
	)

	if (userinput.toLowerCase() !== "y") {
		colorLog(Colors.blue, `User cancelled the deployment!\n`)
		throw "Cancelled"
	}
}

async function deployContract(
	config: IDeployConfig,
	hre: HardhatRuntimeEnvironment
) {
	const helper: DeploymentHelper = new DeploymentHelper(config, hre)

	const vstOracle = await helper.deployUpgradeableContractWithName(
		"PriceOracleV1",
		"VSTOracle",
		"setUp",
		config.VstDeployment!.oracleName,
		18
	)

	await helper.sendAndWaitForTransaction(
		vstOracle.registerTrustedNode(config.VstDeployment?.trustedNode)
	)

	await helper.sendAndWaitForTransaction(
		vstOracle.transferOwnership(config.VstDeployment?.admin)
	)
}
