use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Beast {
    #[key]
    beast_id: u32,
    player_id: ContractAddress,
    beast_type: BeastType,
    hp: u32,
    mp: u32,
    strength: u32,
    defense: u32,
    equipped_weapon: felt252,
    wpn_power: u8,
    equipped_armor: felt252,
    armor_power: u32,
    experience_to_nex_level: u32,
    level: u8,
}

#[derive(Serde, Copy, Drop, Introspect)]
enum BeastType {
    Normal,
    Legendary
}


