use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use bytebeasts::{
    models::{player::Player, potion::Potion, bag::Bag},
};

#[dojo::interface]
trait IBagAction {
    fn init_bag(ref world: IWorldDispatcher, bag_id: u32, player_id: u32);
    fn add_item(ref world: IWorldDispatcher, player_id: u32, potion: Potion);
    fn take_out_item(ref world: IWorldDispatcher, player_id: u32) -> Potion;
}

#[dojo::contract]
mod bag_system {
    use super::IBagAction;
    use array::ArrayTrait; 
    use bytebeasts::{
        models::{player::Player, potion::Potion, bag::Bag},
    };

    const MAX_BAG_SIZE: usize = 10;

    #[abi(embed_v0)]
    impl BagActionImpl of IBagAction<ContractState> {
        fn init_bag(ref world: IWorldDispatcher, bag_id: u32, player_id: u32) {
            let bag = Bag {
                bag_id: bag_id,
                player_id: player_id,
                max_capacity: MAX_BAG_SIZE,
                potions: ArrayTrait::new(),
            };

            set!(world, (bag))
        }

        fn add_item(ref world: IWorldDispatcher, player_id: u32, potion: Potion) {
            let mut bag = get!(world,player_id,(Bag));
            bag.potions.append(potion);
            set!(world, (bag));
        }

        fn take_out_item(ref world: IWorldDispatcher, player_id: u32) -> Potion {
            let mut bag = get!(world,player_id,(Bag));
            let potion = bag.potions.pop_front().unwrap();
            set!(world, (bag));
            return potion;
        }
    }
}