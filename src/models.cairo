use starknet::ContractAddress;

#[derive(Serde, Copy, Drop, Introspect)]
pub enum WorldElements {
    Crystal,
    Draconic,
    Shadow,
    Light,
    Titanium,
}

impl WorldElementsIntoFelt252 of Into<WorldElements, felt252> {
    fn into(self: WorldElements) -> felt252 {
        match self {
            WorldElements::Crystal => 0,
            WorldElements::Draconic => 1,
            WorldElements::Shadow => 2,
            WorldElements::Light => 3,
            WorldElements::Titanium => 4,
        }
    }
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Beast {
    #[key]
    pub beast_id: u32,
    pub beast_name: felt252,
    pub beast_type: WorldElements,
    pub beast_description: felt252,
    pub player_id: u32,
    pub hp: u32,
    pub current_hp: u32,
    pub attack: u32,
    pub defense: u32,
    pub mt1: u32,
    pub mt2: u32,
    pub mt3: u32,
    pub mt4: u32,
    pub level: u32,
    pub experience_to_next_level: u64,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Battle {
    #[key]
    pub battle_id: u32,
    pub player_id: u32,
    pub opponent_id: u32,
    pub active_beast_player: u32,
    pub active_beast_opponent: u32,
    pub battle_active: u32,
    pub turn: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Mt {
    #[key]
    pub mt_id: u32,
    pub mt_name: felt252,
    pub mt_type: WorldElements,
    pub mt_power: u32,
    pub mt_accuracy: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Player {
    #[key]
    pub player_id: u32,
    pub player_name: felt252,
    pub beast_1: u32,
    pub beast_2: u32,
    pub beast_3: u32,
    pub beast_4: u32,
    pub potions: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Potion {
    #[key]
    pub potion_id: u32,
    pub potion_name: felt252,
    pub potion_effect: u32,
}
