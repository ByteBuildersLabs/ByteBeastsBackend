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
    fn setWorld(ref world: IWorldDispatcher);
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

        fn setWorld(ref world: IWorldDispatcher) {
            set!(
                world,
                (
                    Beast { beast_id: 1, beast_name: 1, beast_type: 1, beast_description: 1, player_id: 1, hp: 1, current_hp: 1, attack: 1, defense: 1, mt1: 1, mt2: 1, mt3: 1, mt4: 1, level: 1, experience_to_nex_level: 1  }
                )
            );
        }
    }
}
