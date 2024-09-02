#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Potion {
    #[key]
    pub potion_id: u32,
    pub potion_name: felt252,
    pub potion_effect: u32,
}

#[cfg(test)]
mod tests {
    use bytebeasts::models::potion::Potion;

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