use super::potion::Potion;
use array::ArrayTrait;

#[derive(Drop, Serde)]
#[dojo::model]
struct Bag {
    #[key]
    pub bag_id: u32,
    #[key]
    pub player_id: u32,
    pub max_capacity: u32,
    pub potions: Array<Potion>,
}

#[cfg(test)]
mod tests {
    use bytebeasts::{models::{bag::Bag, potion::Potion}};
    use array::ArrayTrait; 

    #[test]
    fn test_bag_initialization() {
        let mut bag = Bag {
            bag_id: 1,
            player_id: 1,
            max_capacity: 10,
            potions: ArrayTrait::new(),
        };

        let potion = Potion {
            potion_id: 1,
            potion_name: 'Restore everything',
            potion_effect: 50,
        };
        bag.potions.append(potion);

        assert_eq!(bag.bag_id, 1, "Bag ID should be 1");
        assert_eq!(bag.player_id, 1, "Player ID should be 1");
        assert_eq!(bag.potions.len(), 1, "Bag should have 1 potion");
        assert_eq!(bag.max_capacity, 10, "Bag should have a max capacity of 10");
        assert_eq!(bag.potions.pop_front().unwrap().potion_id, 1, "Bag potion ID should be 1");
    }
}
