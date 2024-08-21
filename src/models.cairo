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

// Testing side
#[generate_trait]
impl BeastImpl of BeastTrait {
    fn exist(self: Beast) -> bool {
        self.hp > 0
    }
}
#[cfg(test)]
mod tests {
    use super::{Beast, Player, BeastTrait, WorldElements};

    #[test]
    fn test_beast_exist() {
        let beast = Beast {
            beast_id: 1,
            beast_name: 0,
            beast_type: WorldElements::Crystal,
            beast_description: 0,
            player_id: 1,
            hp: 100,
            current_hp: 100,
            attack: 50,
            defense: 40,
            mt1: 1, // Fire Blast
            mt2: 2, // Ember
            mt3: 3, // Flame Wheel
            mt4: 4, // Fire Punch
            level: 5,
            experience_to_next_level: 1000,
        };
        assert(beast.exist(), 'Beast is alive');
        assert_eq!(beast.hp, 100, "HP should be initialized to 100");
    }

    #[test]
    fn test_player_initialization() {
        let player = Player {
            player_id: 1,
            player_name: 'Hero',
            beast_1: 1,
            beast_2: 2,
            beast_3: 3,
            beast_4: 4,
            potions: 5,
        };

        assert_eq!(player.player_name, 'Hero', "Player name should be 'Hero'");
        assert_eq!(player.potions, 5, "Player should have 5 potions");
    }

    #[test]
    #[available_gas(200000)]
    fn test_beast_defeat() {
        let mut beast = Beast {
            beast_id: 1,
            beast_name: 'Dragon',
            beast_type: WorldElements::Draconic,
            beast_description: 'A mighty dragon',
            player_id: 1,
            hp: 100,
            current_hp: 10, // Bestia cerca de ser derrotada
            attack: 50,
            defense: 40,
            mt1: 1,
            mt2: 2,
            mt3: 3,
            mt4: 4,
            level: 5,
            experience_to_next_level: 1000,
        };

        // Simulate an attack that would defeat the beast
        let damage = 20;
        if damage >= beast.current_hp {
            beast.current_hp = 0;
        } else {
            beast.current_hp -= damage;
        }

        assert_eq!(beast.current_hp, 0, "Beast should have 0 HP after being defeated");
        // assert!(!beast.exist(), "Beast should be defeated");
    }
}
