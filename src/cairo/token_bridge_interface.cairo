use starknet::ClassHash;
use starknet::ContractAddress;

#[starknet::interface]
trait ITokenBridge<TContractState> {
    fn get_version(self: @TContractState) -> felt252;
    fn get_identity(self: @TContractState) -> felt252;
    fn get_l1_token(self: @TContractState, l2_token: ContractAddress) -> ContractAddress;
    fn get_l1_bridge(self: @TContractState) -> ContractAddress;
    fn get_l2_token(self: @TContractState, l1_token: ContractAddress) -> ContractAddress;
    fn get_remaining_withdrawal_quota(self: @TContractState, l1_token: ContractAddress) -> u256;
    fn initiate_withdraw(ref self: TContractState, l1_recipient: ContractAddress, amount: u256);
    fn initiate_token_withdraw(
        ref self: TContractState,
        l1_token: ContractAddress,
        l1_recipient: ContractAddress,
        amount: u256,
    );
    fn initiate_token_withdraw_with_id(
        ref self: TContractState,
        l1_token: ContractAddress,
        l1_recipient: ContractAddress,
        amount: u256,
        id: u64,
    );
}

