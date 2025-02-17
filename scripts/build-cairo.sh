#!/bin/bash
pushd $(dirname $0)/..
set -e
mkdir -p cairo_contracts

scripts/starknet-compile.py src --contract-path src::strk::erc20_lockable::ERC20Lockable \
    cairo_contracts/starkgate_contracts_ERC20Lockable.contract_class.json
    
scripts/starknet-compile.py src --contract-path src::update_712_vars_eic::Update712VarsEIC \
    cairo_contracts/starkgate_contracts_Update712VarsEIC.contract_class.json

scripts/starknet-compile.py src --contract-path src::roles_init_eic::RolesExternalInitializer \
    cairo_contracts/starkgate_contracts_RolesExternalInitializer.contract_class.json

scripts/starknet-compile.py src --contract-path src::legacy_bridge_eic::LegacyBridgeUpgradeEIC \
    cairo_contracts/starkgate_contracts_LegacyBridgeUpgradeEIC.contract_class.json

scripts/starknet-compile.py src --contract-path src::token_bridge::TokenBridge \
    cairo_contracts/starkgate_contracts_TokenBridge.contract_class.json

scripts/starknet-compile.py src --contract-path openzeppelin::token::erc20::presets::erc20_votes_lock::ERC20VotesLock \
    cairo_contracts/starkgate_contracts_ERC20VotesLock.contract_class.json

scripts/starknet-compile.py src --contract-path openzeppelin::token::erc20_v070::erc20::ERC20 \
    cairo_contracts/starkgate_contracts_ERC20.contract_class.json

.downloads/cairo/bin/starknet-sierra-compile \
    cairo_contracts/starkgate_contracts_ERC20Lockable.contract_class.json \
    cairo_contracts/starkgate_contracts_ERC20Lockable.compiled_contract_class.json

.downloads/cairo/bin/starknet-sierra-compile \
    cairo_contracts/starkgate_contracts_Update712VarsEIC.contract_class.json \
    cairo_contracts/starkgate_contracts_Update712VarsEIC.compiled_contract_class.json

.downloads/cairo/bin/starknet-sierra-compile \
    cairo_contracts/starkgate_contracts_RolesExternalInitializer.contract_class.json \
    cairo_contracts/starkgate_contracts_RolesExternalInitializer.compiled_contract_class.json

.downloads/cairo/bin/starknet-sierra-compile \
    cairo_contracts/starkgate_contracts_LegacyBridgeUpgradeEIC.contract_class.json \
    cairo_contracts/starkgate_contracts_LegacyBridgeUpgradeEIC.compiled_contract_class.json

.downloads/cairo/bin/starknet-sierra-compile \
    cairo_contracts/starkgate_contracts_TokenBridge.contract_class.json \
    cairo_contracts/starkgate_contracts_TokenBridge.compiled_contract_class.json
    
.downloads/cairo/bin/starknet-sierra-compile \
    cairo_contracts/starkgate_contracts_ERC20VotesLock.contract_class.json \
    cairo_contracts/starkgate_contracts_ERC20VotesLock.compiled_contract_class.json

set +e
popd
