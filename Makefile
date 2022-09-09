# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

FORK_MAINNET_RPC =  --fork-url ${ARBITRUM_RPC}
HARDHAT_COMPILE = npx hardhat compile
FORGE_CLEAN = forge clean
E2E_ONLY = --match-path "src/test/e2e/*"
UNIT_ONLY = --no-match-path "src/test/e2e/*"
SCRIPT = deploy;

# How to use $(EXTRA) or $(NETWORK)
# define it with your command. 
# e.g: make test EXTRA='-vvv --match-contract MyContractTest'
# e.g: make deploy-testnet NETWORK='arbitrumTestnet'

# deps
update:; forge update
remappings:; forge remappings > remappings.txt

# commands
build  :; $(FORGE_CLEAN) && forge build 
clean  :; $(FORGE_CLEAN)

# test
test   :; $(FORGE_CLEAN) && forge test $(UNIT_ONLY) $(EXTRA)
test-e2e   :; $(FORGE_CLEAN) && forge test $(FORK_MAINNET_RPC) $(E2E_ONLY) $(EXTRA)

# Gas Snapshots
snapshot :; $(FORGE_CLEAN) && forge snapshot $(EXTRA)
snapshot-fork :; $(FORGE_CLEAN) && forge snapshot --snap .gas-snapshot-fork $(FORK_MAINNET_RPC) $(EXTRA)

# Hardhat Deployments
deploy-local :; $(HARDHAT_COMPILE) && npx hardhat $(SCRIPT) --network local --env localhost
deploy-testnet :; $(HARDHAT_COMPILE) && npx hardhat $(SCRIPT) --network $(NETWORK) --env testnet
deploy-mainnet :; $(HARDHAT_COMPILE) && npx hardhat $(SCRIPT) --network $(NETWORK) --env mainnet
