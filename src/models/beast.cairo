use starknet::ContractAddress;
use super::world_elements::WorldElements;

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


#[generate_trait]
impl BeastImpl of BeastTrait {
    fn exist(self: Beast) -> bool {
        self.hp > 0
    }
}

#[cfg(test)]
mod tests {
    use bytebeasts::{models::{beast::{Beast, BeastTrait}, world_elements::WorldElements},};

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
}
