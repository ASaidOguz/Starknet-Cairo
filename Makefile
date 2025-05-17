# ========= StarkNet Makefile =========

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
