#[cfg(test)]
mod tests {
    use starknet::ContractAddress;

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait}; 
    use dojo::utils::test::{spawn_test_world, deploy_contract};

    use bytebeasts::{
        systems::{battle::{battle_system, IBattleActionsDispatcher, IBattleActionsDispatcherTrait}},
        models::{{Battle, battle, Player, player, Beast, beast, Mt, mt, Potion, potion}}
    };


    #[test]
     fn setup_world() -> (IWorldDispatcher, IBattleActionsDispatcher) {
        let mut models = array![
            beast::TEST_CLASS_HASH,
            mt::TEST_CLASS_HASH,
            player::TEST_CLASS_HASH,
            potion::TEST_CLASS_HASH,
            battle::TEST_CLASS_HASH,
            
        ];
        
        let world = spawn_test_world("bytebeasts", models);
 
        let contract_address = world.deploy_contract('salt', battle_system::TEST_CLASS_HASH.try_into().unwrap());

        let battle_system = IBattleActionsDispatcher { contract_address };

        world.grant_writer(dojo::utils::bytearray_hash(@"bytebeasts"), contract_address);
 
        (world, battle_system)
    }


    #[test]
    fn test_init_battle() {
        let (world, battle_system) = setup_world();

        let player_ash = Player {
            player_id: 1,
            player_name: 'Ash',
            beast_1: 1, // Beast 1 assigned
            beast_2: 0, // No beast assigned
            beast_3: 0, // No beast assigned
            beast_4: 0, // No beast assigned
            potions: 2
        };

        let opponent_red = Player {
            player_id: 2,
            player_name: 'Red',
            beast_1: 1, // Beast 1 assigned
            beast_2: 0, // No beast assigned
            beast_3: 0, // No beast assigned
            beast_4: 0, // No beast assigned
            potions: 2
        };

        set!(world,(player_ash));

        set!(world,(opponent_red));

        let battle_id = battle_system.init_battle(player_ash.player_id, opponent_red.player_id);

        let battle = get!(world, battle_id,(Battle));

        assert!(battle.battle_id == 1, "Wrong battle id");
        assert!(battle.player_id == 1, "Wrong player id");
        assert!(battle.opponent_id == 2, "Wrong opponent id");
        assert!(battle.active_beast_player == 1, "Wrong player beast id");
        assert!(battle.active_beast_opponent == 1, "Wrong oppponent beast id");
        assert!(battle.battle_active == 1, "Wrong active state");
        assert!(battle.turn == 0, "Wrong turn");    
    }

    #[test]
    fn test_setup() {
        let (_, _,) = setup_world();
    }
}