-include .env

help:
	@echo "Usage:"
	@echo "make create_key  \n[creates key.json file and exports it as env variable]"
	@echo ""
	@echo "make create_account \n[after creation you need to fund your account in starknet faucet]"
	@echo ""
	@echo "  make declare_contract [ARGS=...]\n    example: make deploy FOLDER_NAME="first_contract" CONTRACT_NAME="hello_cairo""
	@echo ""
	@echo "  make deploy [ARGS=...]\n    example: make deploy CONTRACT_NAME="first_cairo" ARGS="starkli""
#key creation
create_key:
	@echo "creating key..."
	@starkli signer keystore new key.json
	@echo "key created dont forget to run  "export STARKNET_KEYSTORE="key.json"""
#account creation
create_account:
	@echo "creating account..."
	@starkli account oz init account.json
	@echo "account created now please fund and deploy the account"
#account deployment
deploy_account:
	@echo "account deployment in progress"
	@starkli account deploy account.json
	@echo "account deployment completed dont forget to run  "export STARKNET_ACCOUNT="account.json"""
#build the current project
build:
	@scarb build
#Declare contract and prepare for deployment
declare_contract:
	@starkli declare --account $(STARKNET_ACCOUNT) --watch ./target/dev/$(FOLDER_NAME)_$(CONTRACT_NAME).sierra.json
	@class_hash_value=$$(starkli class-hash target/dev/$(FOLDER_NAME)_$(CONTRACT_NAME).sierra.json); \
	 json_object="{ \"class_hash\": \"$$class_hash_value\" }"; \
	 echo "$$json_object" > $(CONTRACT_NAME)_class_hash.json
#Specialized deployment for string types
deploy_contract:
	@CLASS_HASH=$$(jq -r '.class_hash' $(CONTRACT_NAME)_class_hash.json); \
    SHORT_STRING=$$( starkli to-cairo-string $(ARGS));	\
	starkli deploy $$CLASS_HASH $$SHORT_STRING





