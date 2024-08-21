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

#[generate_trait]
impl BeastImpl of BeastTrait {
    fn exist(self: Beast) -> bool {
        self.hp > 0
    }
}

#[cfg(test)]
mod tests {
    use super::{Battle, Beast, Player, Mt, Potion, BeastTrait, WorldElements};

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
    fn test_battle_initialization() {
        let battle = Battle {
            battle_id: 1,
            player_id: 1,
            opponent_id: 2,
            active_beast_player: 1,
            active_beast_opponent: 2,
            battle_active: 1,
            turn: 1,
        };

        assert_eq!(battle.battle_id, 1, "Battle ID should be 1");
        assert_eq!(battle.player_id, 1, "Player ID should be 1");
        assert_eq!(battle.opponent_id, 2, "Opponent ID should be 2");
        assert_eq!(battle.battle_active, 1, "Battle should be active");
        assert_eq!(battle.turn, 1, "Turn should be 1");
    }

    #[test]
    fn test_mt_initialization() {
        let mt = Mt {
            mt_id: 1,
            mt_name: 0, // Assume mt_name is felt252 type
            mt_type: WorldElements::Light,
            mt_power: 75,
            mt_accuracy: 90,
        };

        assert_eq!(mt.mt_id, 1, "MT ID should be 1");
        assert_eq!(mt.mt_power, 75, "MT power should be 75");
        assert_eq!(mt.mt_accuracy, 90, "MT accuracy should be 90");
    }

    #[test]
    fn test_potion_initialization() {
      let potion = Potion {
          potion_id: 1,
          potion_name: 0, // Assume potion_name is felt252 type
          potion_effect: 50, // Heals 50 HP
      };

      assert_eq!(potion.potion_id, 1, "Potion ID should be 1");
      assert_eq!(potion.potion_effect, 50, "Potion effect should be 50");
    }
}
