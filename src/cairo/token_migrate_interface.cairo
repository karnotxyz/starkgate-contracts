use starknet::ContractAddress;

#[starknet::interface]
trait ITokenMigrate<TContractState> {
    fn get_new_l2_token(self: @TContractState) -> ContractAddress;
    fn get_deprecated_l2_token(self: @TContractState) -> ContractAddress;
    fn migrate_balance_to_new_token(ref self: TContractState);
    fn migrate_balance_to_deprecated_token(ref self: TContractState);
}
