use super::world_elements::WorldElements;

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