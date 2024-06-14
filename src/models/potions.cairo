use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct Potions {
    #[key]
    player: ContractAddress,
    balance: u8,
    healthRecovery: u8,
}
