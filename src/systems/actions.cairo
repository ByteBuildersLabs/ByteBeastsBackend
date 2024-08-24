use bytebeasts::models::Beast;
use bytebeasts::models::Mt;
use bytebeasts::models::Player;
use bytebeasts::models::Coordinates;
use bytebeasts::models::Position;
use bytebeasts::models::Potion;
use bytebeasts::models::WorldElements;

// define the interface
#[dojo::interface]
trait IActions {
    fn setWorld(ref world: IWorldDispatcher);
    fn spawn(ref world: IWorldDispatcher, player_id: u32);
    fn move(ref world: IWorldDispatcher, player_id: u32, new_x: u32, new_y: u32);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};

    use starknet::{ContractAddress, get_caller_address};
    use bytebeasts::models::{Beast, Mt, Player, Coordinates, Position, Potion, WorldElements};

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn setWorld(ref world: IWorldDispatcher) {
            // Set Beasts
            set!(
                world,
                (Beast {
                    beast_id: 1,
                    beast_name: 'Firebeast',
                    beast_type: WorldElements::Draconic(()),
                    beast_description: 'A fiery beast.',
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
                    experience_to_next_level: 1000
                })
            );

            set!(
                world,
                (Beast {
                    beast_id: 2,
                    beast_name: 'Aqua',
                    beast_type: WorldElements::Crystal(()),
                    beast_description: 'A water beast',
                    player_id: 2,
                    hp: 110,
                    current_hp: 110,
                    attack: 45,
                    defense: 50,
                    mt1: 5, // Water Gun
                    mt2: 6, // Bubble
                    mt3: 7, // Aqua Tail
                    mt4: 8, // Hydro Pump
                    level: 5,
                    experience_to_next_level: 1000
                })
            );

            // Set Trainers
            set!(
                world,
                (Player {
                    player_id: 1,
                    player_name: 'Ash',
                    beast_1: 1, // Hellooo
                    beast_2: 0, // No beast assigned
                    beast_3: 0, // No beast assigned
                    beast_4: 0, // No beast assigned
                    potions: 2
                })
            );

            set!(
                world,
                (Player {
                    player_id: 2,
                    player_name: 'Misty',
                    beast_1: 2, // Aqua
                    beast_2: 0, // No beast assigned
                    beast_3: 0, // No beast assigned
                    beast_4: 0, // No beast assigned
                    potions: 3
                })
            );

            // Set Potions
            set!(
                world,
                (Potion {
                    potion_id: 1, potion_name: 'Health Potion', potion_effect: 50
                })
            );

            set!(
                world,
                (Potion {
                    potion_id: 2, potion_name: 'Super Potion', potion_effect: 100
                })
            );

            // Set Mts
            set!(
                world,
                (Mt {
                    mt_id: 1,
                    mt_name: 'Fire Blast',
                    mt_type: WorldElements::Draconic(()),
                    mt_power: 90,
                    mt_accuracy: 85
                })
            );

            set!(
                world,
                (Mt {
                    mt_id: 2,
                    mt_name: 'Ember',
                    mt_type: WorldElements::Crystal(()),
                    mt_power: 40,
                    mt_accuracy: 100
                })
            );

            set!(
                world,
                (Mt {
                    mt_id: 3,
                    mt_name: 'Flame Wheel',
                    mt_type: WorldElements::Draconic(()),
                    mt_power: 60,
                    mt_accuracy: 95
                })
            );

            set!(
                world,
                (Mt {
                    mt_id: 4,
                    mt_name:'Fire Punch',
                    mt_type: WorldElements::Crystal(()),
                    mt_power: 75,
                    mt_accuracy: 100
                })
            );

            set!(
                world,
                (Mt {
                    mt_id: 5,
                    mt_name: 'Water Gun',
                    mt_type: WorldElements::Crystal(()),
                    mt_power: 40,
                    mt_accuracy: 100
                })
            );

            set!(
                world,
                (Mt {
                    mt_id: 6,
                    mt_name: 'Bubble',
                    mt_type: WorldElements::Draconic(()),
                    mt_power: 20,
                    mt_accuracy: 100
                })
            );

            set!(
                world,
                (Mt {
                    mt_id: 7,
                    mt_name: 'Aqua Tail',
                    mt_type: WorldElements::Crystal(()),
                    mt_power: 90,
                    mt_accuracy: 90
                })
            );

            set!(
                world,
                (Mt {
                    mt_id: 8,
                    mt_name: 'Hydro Pump',
                    mt_type: WorldElements::Crystal(()),
                    mt_power: 110,
                    mt_accuracy: 80
                })
            );
        }

        fn spawn(ref world: IWorldDispatcher, player_id: u32) {
            let player_from_world = get!(world, player_id, (Player));
        
            set!(
                world,
                (Position {
                        player: player_from_world,
                        coordinates: Coordinates { x: 10, y: 10 }
                    },
                )
            );
        }

        fn move(ref world: IWorldDispatcher, player_id: u32, new_x: u32, new_y:u32) {
            let player_from_world = get!(world, player_id, (Player));
        
            set!(
                world,
                (Position {
                        player: player_from_world,
                        coordinates: Coordinates { x: new_x, y: new_y }
                    },
                )
            );
        }

    }
}
