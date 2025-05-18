#!/bin/bash

cat > Makefile << 'EOF'
# ========= StarkNet Makefile =========

.PHONY: help start_dev set_account declare_local deploy_contract invoke_string_arg call_string_arg

help:
	@echo "StarkNet Makefile Commands:"
	@echo ""
	@echo "  make start_dev"
	@echo "      Starts starknet-devnet with seed=0."
	@echo ""
	@echo "  make set_account"
	@echo "      Imports a devnet account using sncast with preconfigured private key and address."
	@echo ""
	@echo "  make set_sepolia_account"
	@echo "      Creates a new account on StarkNet Sepolia testnet and saves it under the name 'sepolia'."
	@echo ""
	@echo "  make deploy_sepolia_account"
	@echo "      Deploys the previously created Sepolia account to the network."
	@echo ""
	@echo "  make declare_local CONTRACT_NAME=<contract_name>"
	@echo "      Declares a contract locally using the given name (from Scarb.toml or compiled artifacts)."
	@echo ""
	@echo "  make declare_sepolia CONTRACT_NAME=<contract_name>"
	@echo "      Declares a contract to Sepolia testnet using 'sepolia' account profile."
	@echo ""
	@echo "  make deploy_contract CLASS_HASH=<class_hash> CALLDATA='<comma_separated_values>'"
	@echo "      Deploys a local contract with constructor calldata passed as string (auto-converted to felt252)."
	@echo ""
	@echo "  make deploy_contract_sepolia CLASS_HASH=<class_hash> CALLDATA='<comma_separated_values>'"
	@echo "      Deploys a Sepolia contract using 'sepolia' account and calldata as string."
	@echo ""
	@echo "  make invoke_str ADDRESS=<contract_address> FUNC=<function_name> CALLDATA='<comma_separated_values>'"
	@echo "      Invokes a function on devnet with string calldata converted to felt252."
	@echo ""
	@echo "  make invoke_str_sepolia ADDRESS=<contract_address> FUNC=<function_name> CALLDATA='<comma_separated_values>'"
	@echo "      Invokes a function on Sepolia with string calldata converted to felt252."
	@echo ""
	@echo "  make call_str ADDRESS=<contract_address> FUNC=<function_name>"
	@echo "      Calls a view function on devnet and decodes the result from felt to string."
	@echo ""
	@echo "  make call_str_sepolia ADDRESS=<contract_address> FUNC=<function_name>"
	@echo "      Calls a view function on Sepolia and decodes the result from felt to string."
	@echo ""

start_dev:
	starknet-devnet --seed=0

set_account:
	sncast account import \
	--address=0x064b48806902a367c8598f4f95c305e8c1a1acba5f082d294a43793113115691 \
	--type=oz \
	--url=http://127.0.0.1:5050 \
	--private-key=0x0000000000000000000000000000000071d7bb07b9a64f6f78ac4c816aff4da9 \
	--add-profile=devnet \
	--silent

set_sepolia_account:
	sncast account create --network=sepolia --name=sepolia

deploy_sepolia_account:
	sncast account deploy --network sepolia --name sepolia

declare_local:
	sncast --profile=devnet declare --contract-name=$(CONTRACT_NAME)

declare_sepolia:
	sncast --account=sepolia declare \
	--contract-name=$(CONTRACT_NAME) \
	--network=sepolia

deploy_contract:
	@FELT_ARG=$$(python3 felt252convert.py --to-felt "$(CALLDATA)"); \
	sncast --profile=devnet deploy --class-hash=$(CLASS_HASH) --salt=0 --constructor-calldata=$$FELT_ARG

deploy_contract_sepolia:
	@FELT_ARG=$$(python3 felt252convert.py --to-felt "$(CALLDATA)"); \
	sncast --account=sepolia deploy --class-hash=$(CLASS_HASH) --network sepolia --constructor-calldata=$$FELT_ARG

invoke_str:
	@FELT_ARG=$$(python3 felt252convert.py --to-felt "$(CALLDATA)"); \
	sncast --profile=devnet invoke --contract-address $(ADDRESS) --network sepolia --function $(FUNC) --arguments $$FELT_ARG

invoke_str_sepolia:
	@FELT_ARG=$$(python3 felt252convert.py --to-felt "$(CALLDATA)"); \
	sncast --account=sepolia invoke --contract-address $(ADDRESS) --network sepolia --function $(FUNC) --arguments $$FELT_ARG

call_str:
	@RESULT=$$(sncast --profile=devnet call \
		--contract-address=$(ADDRESS) \
		--function=$(FUNC) | grep -o '0x[0-9a-fA-F]\+'); \
	echo "Raw felt: $$RESULT"; \
	echo -n "Decoded: "; \
	python3 felt252convert.py --to-str-hex $$RESULT

call_str_sepolia:
	@RESULT=$$(sncast --account=sepolia call \
		--contract-address=$(ADDRESS) --network sepolia \
		--function=$(FUNC) | grep -o '0x[0-9a-fA-F]\+'); \
	echo "Raw felt: $$RESULT"; \
	echo -n "Decoded: "; \
	python3 felt252convert.py --to-str-hex $$RESULT
EOF

echo "✅ Makefile created successfully with full help documentation."
