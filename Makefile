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
	@echo "  make declare_local CONTRACT_NAME=<contract_name>"
	@echo "      Declares a contract using the given name (should match your Scarb.toml or compiled artifacts)."
	@echo ""
	@echo "  make deploy_contract CLASS_HASH=<class_hash> CALLDATA='<comma_separated_values>'"
	@echo "      Deploys a contract with constructor calldata passed as string, auto-converted to felt252."
	@echo ""
	@echo "  make invoke_string_arg ADDRESS=<contract_address> FUNC=<function_name> CALLDATA='<comma_separated_values>'"
	@echo "      Invokes a function with calldata passed as string (converted to felt252)."
	@echo ""
	@echo "  make call_string_arg ADDRESS=<contract_address> FUNC=<function_name>"
	@echo "      Calls a view function and decodes the felt252 result back to string."
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

declare_local:
	sncast --profile=devnet declare --contract-name=$(CONTRACT_NAME)

deploy_contract:
	@FELT_ARG=$$(python3 felt252convert.py --to-felt "$(CALLDATA)"); \
	sncast --profile=devnet deploy --class-hash=$(CLASS_HASH) --salt=0 --constructor-calldata=$$FELT_ARG

invoke_string_arg:
	@FELT_ARG=$$(python3 felt252convert.py --to-felt "$(CALLDATA)"); \
	sncast --profile=devnet invoke --contract-address $(ADDRESS) --function $(FUNC) --arguments $$FELT_ARG

call_string_arg:
	@RESULT=$$(sncast --profile=devnet call \
		--contract-address=$(ADDRESS) \
		--function=$(FUNC) | grep -o '0x[0-9a-fA-F]\+'); \
	echo "Raw felt: $$RESULT"; \
	echo -n "Decoded: "; \
	python3 felt252convert.py --to-str-hex $$RESULT
