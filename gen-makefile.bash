#!/bin/bash

SRC_DIR="src"
MAKEFILE_NAME="Makefile"
TMP_MAKEFILE="Makefile.tmp"

echo "Generating $MAKEFILE_NAME from Cairo contracts in $SRC_DIR..."

# Start Makefile with basic devnet commands
cat << 'EOF' > $TMP_MAKEFILE
.PHONY: start_dev set_account set_sepolia_account deploy_sepolia_account test test_coverage clear_coverage

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

# Testing and Coverage
test:
	@echo "Running tests..."
	scarb test

# Coverage Report Generation
PROJECT_NAME := $(shell grep '^name' Scarb.toml | head -n1 | sed 's/name *= *//; s/"//g')
REPORT_DIR ?= coverage_report
REPORTS_BASE ?= /mnt/c/stark-reports/coverage-reports
PROJECT_REPORT_DIR ?= $(REPORTS_BASE)/$(PROJECT_NAME)
WINDOWS_REPORT_DIR = C:\\stark-reports\\coverage-reports\\$(PROJECT_NAME)
CHROME_PATH ?= C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe

test_coverage:
	snforge test --coverage
	genhtml -o $(REPORT_DIR) ./coverage/coverage.lcov
	mkdir -p $(PROJECT_REPORT_DIR)
	cp -r $(REPORT_DIR)/* $(PROJECT_REPORT_DIR)/
	powershell.exe -Command "Start-Process '$(CHROME_PATH)' -ArgumentList '$(WINDOWS_REPORT_DIR)\\index.html'"

clear_coverage:
	cairo-coverage clean
EOF

# Function to extract contract name from lib.cairo's mod statement
extract_mod_name() {
    grep -Po 'mod\s+\K\w+' "$1" | head -n 1
}

# Loop through all .cairo files
find "$SRC_DIR" -type f -name "*.cairo" | while read -r filepath; do
    filename=$(basename "$filepath")
    dirpath=$(dirname "$filepath")

    if [[ "$filename" == "lib.cairo" ]]; then
        cairo_count=$(find "$dirpath" -maxdepth 1 -type f -name "*.cairo" | wc -l)
        if [[ "$cairo_count" -gt 1 ]]; then
            continue
        else
            contract_name=$(extract_mod_name "$filepath")
        fi
    else
        contract_name="${filename%.cairo}"
    fi

    if [[ -z "$contract_name" ]]; then
        echo "⚠️  Could not determine contract name for $filepath"
        continue
    fi

    cat << EOF >> $TMP_MAKEFILE

# Declare and Deploy targets for $contract_name

declare_local_$contract_name:
	@echo "Declaring $contract_name (local)..."
	@mkdir -p deployments/devnet/local
	@if sncast --profile=devnet declare --contract-name=$contract_name > tmp_declare_output.txt 2>&1; then \\
		class_hash=\$\$(grep -o 'class_hash: 0x[0-9a-fA-F]*' tmp_declare_output.txt | cut -d ' ' -f2); \\
		if [ -n "\$\$class_hash" ]; then \\
			timestamp=\$\$(date +%s); \\
			printf '{"class_hash": "%s", "contract_name": "%s", "timestamp": %s}\n' "\$\$class_hash" "$contract_name" "\$\$timestamp" > deployments/devnet/local/$contract_name.json; \\
			echo "✅ Saved class hash: \$\$class_hash to deployments/devnet/local/$contract_name.json"; \\
		else \\
			echo "❌ Failed to extract class hash from output"; \\
			cat tmp_declare_output.txt; \\
		fi; \\
	else \\
		echo "❌ Declaration failed for $contract_name"; \\
		cat tmp_declare_output.txt; \\
	fi; \\
	rm -f tmp_declare_output.txt

declare_sepolia_$contract_name:
	@echo "Declaring $contract_name (sepolia)..."
	@mkdir -p deployments/sepolia/sepolia
	@if sncast --account=sepolia declare --contract-name=$contract_name --network sepolia > tmp_declare_output.txt 2>&1; then \\
		class_hash=\$\$(grep -o 'class_hash: 0x[0-9a-fA-F]*' tmp_declare_output.txt | cut -d ' ' -f2); \\
		if [ -n "\$\$class_hash" ]; then \\
			timestamp=\$\$(date +%s); \\
			printf '{"class_hash": "%s", "contract_name": "%s", "timestamp": %s}\n' "\$\$class_hash" "$contract_name" "\$\$timestamp" > deployments/sepolia/sepolia/$contract_name.json; \\
			echo "✅ Saved class hash: \$\$class_hash to deployments/sepolia/sepolia/$contract_name.json"; \\
		else \\
			echo "❌ Failed to extract class hash from output"; \\
			cat tmp_declare_output.txt; \\
		fi; \\
	else \\
		echo "❌ Declaration failed for $contract_name"; \\
		cat tmp_declare_output.txt; \\
	fi; \\
	rm -f tmp_declare_output.txt

deploy_local_$contract_name:
	@echo "Deploying $contract_name (local)..."
	@mkdir -p deployments/devnet/local
	@if [ ! -f "deployments/devnet/local/$contract_name.json" ]; then \\
		echo "❌ Class hash file not found. Please declare the contract first with: make declare_local_$contract_name"; \\
		exit 1; \\
	fi
	\$(eval CLASS_HASH := \$(shell jq -r '.class_hash' deployments/devnet/local/$contract_name.json))
	@output=\$\$(sncast --profile=devnet deploy \\
		--arguments \$(ARGUMENTS) \\
		--class-hash=\$(CLASS_HASH) \\
		--salt=5 \\
		); \\
	contract_address=\$\$(echo "\$\$output" | grep "contract_address:" | awk '{print \$\$2}'); \\
	transaction_hash=\$\$(echo "\$\$output" | grep "transaction_hash:" | awk '{print \$\$2}'); \\
	timestamp=\$\$(date +%s); \\
	printf '{"contract_address": "%s", "transaction_hash": "%s", "class_hash": "%s", "contract_name": "%s", "timestamp": %s}\n' "\$\$contract_address" "\$\$transaction_hash" "\$(CLASS_HASH)" "$contract_name" "\$\$timestamp" > deployments/devnet/local/$contract_name.deployment.json; \\
	echo "✅ Deployed $contract_name successfully!"; \\
	echo "Contract Address: \$\$contract_address"; \\
	echo "Transaction Hash: \$\$transaction_hash"; \\
	echo "Deployment saved to: deployments/devnet/local/$contract_name.deployment.json"; \\
	echo "\$\$output"

deploy_sepolia_$contract_name:
	@echo "Deploying $contract_name (sepolia)..."
	@mkdir -p deployments/sepolia/sepolia
	@if [ ! -f "deployments/sepolia/sepolia/$contract_name.json" ]; then \\
		echo "❌ Class hash file not found. Please declare the contract first with: make declare_sepolia_$contract_name"; \\
		exit 1; \\
	fi
	\$(eval CLASS_HASH := \$(shell jq -r '.class_hash' deployments/sepolia/sepolia/$contract_name.json))
	@output=\$\$(sncast --account=sepolia deploy \\
		--arguments \$(ARGUMENTS) \\
		--class-hash=\$(CLASS_HASH) \\
		--network sepolia \\
		--salt=5 \\
		); \\
	contract_address=\$\$(echo "\$\$output" | grep "contract_address:" | awk '{print \$\$2}'); \\
	transaction_hash=\$\$(echo "\$\$output" | grep "transaction_hash:" | awk '{print \$\$2}'); \\
	timestamp=\$\$(date +%s); \\
	printf '{"contract_address": "%s", "transaction_hash": "%s", "class_hash": "%s", "contract_name": "%s", "timestamp": %s}\n' "\$\$contract_address" "\$\$transaction_hash" "\$(CLASS_HASH)" "$contract_name" "\$\$timestamp" > deployments/sepolia/sepolia/$contract_name.deployment.json; \\
	echo "✅ Deployed $contract_name successfully!"; \\
	echo "Contract Address: \$\$contract_address"; \\
	echo "Transaction Hash: \$\$transaction_hash"; \\
	echo "Deployment saved to: deployments/sepolia/sepolia/$contract_name.deployment.json"; \\
	echo "\$\$output"
EOF

done

mv "$TMP_MAKEFILE" "$MAKEFILE_NAME"
echo "✅ Makefile generated successfully."