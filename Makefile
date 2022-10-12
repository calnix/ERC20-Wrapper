
# include .env file and export its env vars (-include to ignore error if it does not exist)
-include .env

deploy-wrapper:
	forge create ${WRAPPER_CONTRACT} --private-key ${PRIVATE_KEY_EDGE} --rpc-url ${RINKEBY_ARBITRUM_RPC} --constructor-args <>

verify-wrapper:
	forge verify-contract --chain-id ${RINKEBY_ARBITRUM_RPC_CHAINID} --compiler-version v0.8.13+commit.abaa5c0e ${WRAPPER_CONTRACT_ADRDRESS} ${WRAPPER_CONTRACT} ${ETHERSCAN_API_KEY} --num-of-optimizations 200 --flatten --constructor-args 0x0000000000000000000000000000000000000000000000000000000000000000

verify-check-wrapper:
	forge verify-check --chain-id ${RINKEBY_ARBITRUM_RPC_CHAINID} ${WRAPPER_GUID} ${ETHERSCAN_API_KEY}

deploy-vault:
	forge create ${ETHWRAPPER_CONTRACT} --private-key ${PRIVATE_KEY_EDGE} --rpc-url ${RINKEBY_ARBITRUM_RPC} --constructor-args "0xfac14d6d486542c1d71b65745d8d881e7d9eb8e1"

verify-vault:
	forge verify-contract --chain-id ${RINKEBY_ARBITRUM_RPC_CHAINID} --compiler-version v0.8.13+commit.abaa5c0e ${ETHWRAPPER_CONTRACT_ADDRESS} ${ETHWRAPPER_CONTRACT} ${ETHERSCAN_API_KEY} --num-of-optimizations 200 --flatten --constructor-args 0x000000000000000000000000fac14d6d486542c1d71b65745d8d881e7d9eb8e1

verify-check-vault:
	forge verify-check --chain-id ${RINKEBY_ARBITRUM_RPC_CHAINID} ${ETHWRAPPER_GUID} ${ETHERSCAN_API_KEY}