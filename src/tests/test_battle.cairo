#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::test_utils::{spawn_test_world, deploy_contract};
    use bytebeasts::models::{Beast, Mt, Player, Potion, Battle};
    use bytebeasts::battle::{battle_system,IActionsDispatcher,IActionsDispatcherTrait};


    #[test]
     // helper setup function
     fn setup_world() -> (IWorldDispatcher, IActionsDispatcher) {
        // models
        let mut models = array![
            Beast::TEST_CLASS_HASH,
            Mt::TEST_CLASS_HASH,
            Player::TEST_CLASS_HASH,
            Potion::TEST_CLASS_HASH,
            Battle::TEST_CLASS_HASH,
            
        ];
        // deploy world with models
        let world = spawn_test_world(models);
 
        // deploy systems contract
        let contract_address = world.deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let battle = IActionsDispatcher { contract_address };
 
        (world, battle)
    }

    fn test_init_battle() {
        
    }
}