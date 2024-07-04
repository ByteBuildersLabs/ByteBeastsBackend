use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Beast {
    #[key]
    beast_id: u32,
    player_id: ContractAddress,
    beast_type: BeastType,
    hp: u32,
    mp: u64,
    strength: u64,
    defense: u64,
    equipped_weapon: felt252,
    wpn_power: u8,
    equipped_armor: felt252,
    armor_power: u64,
    experience_to_nex_level: u64,
    level: u8,
}

#[derive(Serde, Copy, Drop, Introspect)]
enum BeastType {
    Normal,
    Legendary
}


