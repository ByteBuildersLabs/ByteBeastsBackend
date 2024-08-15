use bytebeasts::models::Beast;
use bytebeasts::models::Mt;
use bytebeasts::models::Player;
use bytebeasts::models::Potion;

// define the interface
#[dojo::interface]
trait IActions {
    fn attack(ref world: IWorldDispatcher);
    fn usePotion(ref world: IWorldDispatcher);
    fn flee(ref world: IWorldDispatcher);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};

    use starknet::{ContractAddress, get_caller_address};
    use bytebeasts::models::{Beast, Mt, Player, Potion};

    #[derive(Copy, Drop, Serde)]
    #[dojo::model]
    #[dojo::event]
    struct Message {
        #[key]
        player: ContractAddress,
        message: felt252,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        
        fn attack(ref world: IWorldDispatcher) {
            let player = get_caller_address();
        }

        fn usePotion(ref world: IWorldDispatcher) {
            let player = get_caller_address();
        }

        fn flee(ref world: IWorldDispatcher) {
            let player = get_caller_address();
        }
    }
}
