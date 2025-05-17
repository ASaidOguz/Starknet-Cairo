#!/bin/bash

cat << 'EOF' > Makefile
# ========= StarkNet Makefile =========

start_dev:
\tstarknet-devnet --seed=0

set_account:
\tsncast account import \\
\t--address=0x064b48806902a367c8598f4f95c305e8c1a1acba5f082d294a43793113115691 \\
\t--type=oz \\
\t--url=http://127.0.0.1:5050 \\
\t--private-key=0x0000000000000000000000000000000071d7bb07b9a64f6f78ac4c816aff4da9 \\
\t--add-profile=devnet \\
\t--silent

declare_local:
\tsncast --profile=devnet declare --contract-name=\$(CONTRACT_NAME)

deploy_contract:
\tsncast --profile=devnet deploy --class-hash=\$(CLASS_HASH) --salt=0 --constructor-calldata=\$(CALLDATA)

call_contract:
\tsncast --profile=devnet call \\
\t--contract-address=\$(ADDRESS) \\
\t--function=\$(FUNCTION) \\
\t--calldata=\$(ARGUMENTS)

EOF

echo "✅ Makefile created."
