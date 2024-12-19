// An EIC contract to prepare l2-token bridge for token migration.
#[starknet::contract]
mod BridgeMigrationPrepEIC {
    use src::mintable_token_interface::{IMintableTokenDispatcher, IMintableTokenDispatcherTrait};
    use starknet::{
        ContractAddress, get_contract_address, get_block_timestamp, EthAddress,
        EthAddressIntoFelt252, EthAddressSerde
    };
    use src::erc20_interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use src::replaceability_interface::IEICInitializable;

    #[storage]
    struct Storage {
        // Mapping from between l1<->l2 token addresses.
        l1_l2_token_map: LegacyMap<EthAddress, ContractAddress>,
        l2_l1_token_map: LegacyMap<ContractAddress, EthAddress>,
        // `l2_token` is a legacy storage variable from older versions.
        l2_token: ContractAddress,
        // `deprecated_l2_token` is a variable storing the address
        // of the deprecated l2_token in a scenario of migration of an l2_token
        // from the contract addressed deprecated_l2_token to the one addressed l2_token.
        deprecated_l2_token: ContractAddress,
    }

    #[abi(embed_v0)]
    impl EICInitializable of IEICInitializable<ContractState> {
        fn eic_initialize(ref self: ContractState, eic_init_data: Span<felt252>) {
            // Params: deprecated_token_address, new_token_address.
            assert(eic_init_data.len() == 2, 'EIC_INIT_DATA_LEN_MISMATCH_2');

            let deprecated_token_address: ContractAddress = (*eic_init_data[0]).try_into().unwrap();
            let new_token_address: ContractAddress = (*eic_init_data[1]).try_into().unwrap();

            self.replace_l2_token(:deprecated_token_address, :new_token_address);
        }
    }

    #[generate_trait]
    impl internals of _internals {
        fn check_token_similarity(
            self: @ContractState, token1: ContractAddress, token2: ContractAddress
        ) {
            let dispatcher1 = IERC20Dispatcher { contract_address: token1 };
            let dispatcher2 = IERC20Dispatcher { contract_address: token2 };

            assert(dispatcher1.name() == dispatcher2.name(), 'TOKEN_NAME_DIFFERENT');
            assert(dispatcher1.symbol() == dispatcher2.symbol(), 'TOKEN_SYMBOL_DIFFERENT');
            assert(dispatcher1.decimals() == dispatcher2.decimals(), 'TOKEN_DECIMALS_DIFFERENT');
        }

        fn check_permitted_minter(self: @ContractState, token_address: ContractAddress) {
            let token = IMintableTokenDispatcher { contract_address: token_address };
            token.permissioned_mint(account: get_contract_address(), amount: 0);
            token.permissioned_burn(account: get_contract_address(), amount: 0);
        }

        fn replace_l2_token(
            ref self: ContractState,
            deprecated_token_address: ContractAddress,
            new_token_address: ContractAddress
        ) {
            assert(deprecated_token_address != new_token_address, 'IDENTICAL_TOKEN_ADDRESSES');

            // Check that we replace from the correct token.
            assert(self.l2_token.read() == deprecated_token_address, 'INCORRECT_TOKEN_ADDRESS');

            // Check that we replace similar tokens, i.e. of the same name, symbol & decimals.
            self
                .check_token_similarity(
                    token1: deprecated_token_address, token2: new_token_address
                );

            // Check that the bridge is permitted to mint & burn the new token.
            self.check_permitted_minter(token_address: new_token_address);

            // Set l2 token storage variables.
            self.deprecated_l2_token.write(deprecated_token_address);
            self.l2_token.write(new_token_address);

            // Update L1-L2 & L2-L1 maps.
            let l1_token = self.l2_l1_token_map.read(deprecated_token_address);

            // Erase l2_l1 entry for the deprecated l2 token.
            self.l2_l1_token_map.write(deprecated_token_address, Zeroable::zero());

            // Write updated L1-L2 token mapping.
            self.l1_l2_token_map.write(l1_token, new_token_address);
            self.l2_l1_token_map.write(new_token_address, l1_token);
        }
    }
}

