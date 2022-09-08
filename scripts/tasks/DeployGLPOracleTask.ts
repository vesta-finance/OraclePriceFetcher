import { HardhatRuntimeEnvironment } from "hardhat/types/runtime"

import { addColor, colorLog, Colors } from "../utils/ColorConsole"
import readline from "readline-sync"
import { IDeployConfig } from "../config/DeployConfig"
import { DeploymentHelper } from "../utils/DeploymentHelper"

export default async function deployGLP(
	params: any,
	hre: HardhatRuntimeEnvironment
): Promise<void> {
	const deploySettings: IDeployConfig = {
		TX_CONFIRMATIONS: 1,
		GLPOracleConfig: {
			glpManager: "0x321F653eED006AD1C29D174e17d96351BDe22649" ,
			gmxVault: "0x489ee077994B6658eAfA855C308275EAd8097C4A",
			glpToken: "0x4277f8F2c384827B5273592FF7CeBd9f2C1ac258",
		}
	}

	colorLog(
		Colors.yellow,
		`\nExecuting Deploy | Network: ${hre.network.name} | --env: ${params.env}\n`
	)
	switch (params.env.toLowerCase()) {
		case "mainnet":
			validUserIntention()
			break
		case "testnet":
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
		"GLPOracle",
		"GLPOracle",
		"setUp",
		config.GLPOracleConfig!.glpToken,
		config.GLPOracleConfig!.glpManager,
		config.GLPOracleConfig!.gmxVault
	)

}
