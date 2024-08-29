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