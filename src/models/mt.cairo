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

#[cfg(test)]
mod tests {
    use bytebeasts::{models::{mt::Mt, world_elements::WorldElements},};

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
}
