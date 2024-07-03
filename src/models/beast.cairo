use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct Beast {
    #[key]
    beast_id: u32,
    player_id: ContractAddress,
    beast_type: BeastType,
    hp: u64,
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

impl BeastTypeIntoFelt252 of Into<BeastType, felt252> {
    fn into(self: BeastType) -> felt252 {
        match self {
            BeastType::Normal => 0,
            BeastType::Legendary => 1,
        }
    }
}
