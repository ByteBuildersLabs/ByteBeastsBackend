#[cfg(test)]
mod tests {
    use starknet::ContractAddress;

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait}; 
    use dojo::utils::test::{spawn_test_world, deploy_contract};

    use bytebeasts::{
        systems::{bag::{bag_system, IBagActionDispatcher, IBagActionDispatcherTrait}},
    };

    use bytebeasts::{
        models::bag::{{Bag, bag}},
        models::player::{{Player, player}},
        models::potion::{{Potion, potion}},
    };


    // Helper function
    // This function create the world and define the required models
    #[test]
     fn setup_world() -> (IWorldDispatcher, IBagActionDispatcher) {
        let mut models = array![
            bag::TEST_CLASS_HASH,
            player::TEST_CLASS_HASH,
            potion::TEST_CLASS_HASH,
            
        ];
        
        let world = spawn_test_world("bytebeasts", models);
 
        let contract_address = world.deploy_contract('salt', bag_system::TEST_CLASS_HASH.try_into().unwrap());

        let bag_system = IBagActionDispatcher { contract_address };

        world.grant_writer(dojo::utils::bytearray_hash(@"bytebeasts"), contract_address);
 
        (world, bag_system)
    }

    
    #[test]
    fn test_setup_player_bag()  -> (IWorldDispatcher, IBagActionDispatcher) {
        let (world, bag_system) = setup_world();

        let player_ash = Player {
            player_id: 1,
            player_name: 'Ash',
            beast_1: 1, // Beast 1 assigned
            beast_2: 0, // No beast assigned
            beast_3: 0, // No beast assigned
            beast_4: 0, // No beast assigned
            potions: 2
        };

        let bag = Bag {
            bag_id: 1,
            player_id: 1,
            max_capacity: 10,
            potions: ArrayTrait::new(),
        };
        
        set!(world,(player_ash));

        set!(world,(bag));

        (world, bag_system)
    }

    #[test]
    fn test_setup() {
        let (_, _,) = setup_world();
        let (_, _,) = test_setup_player_bag();
        
    }
}