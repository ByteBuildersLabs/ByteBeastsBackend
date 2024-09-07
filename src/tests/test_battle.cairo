#[cfg(test)]
mod tests {
    use starknet::ContractAddress;

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait}; 
    use dojo::utils::test::{spawn_test_world, deploy_contract};

    use bytebeasts::{
        systems::{battle::{battle_system, IBattleActionsDispatcher, IBattleActionsDispatcherTrait}},
    };

    use bytebeasts::{
        models::battle::{{Battle, battle}},
        models::beast::{{Beast, beast}},
        models::mt::{{Mt, mt}},
        models::player::{{Player, player}},
        models::potion::{{Potion, potion}},
        models::world_elements::{{WorldElements}}
    };


    // Helper function
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

    // Helper function
    #[test]
    fn setup_battle() -> (IWorldDispatcher, IBattleActionsDispatcher) {
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

        let beast_1 = Beast {
            beast_id: 1,
            beast_name: 'Firebeast',
            beast_type: WorldElements::Draconic(()),
            beast_description: 'A fiery beast.',
            player_id: 1,
            hp: 10,
            current_hp: 10,
            attack: 1,
            defense: 1,
            mt1: 1, // Fire Blast
            mt2: 2, // Ember
            mt3: 3, // Flame Wheel
            mt4: 4, // Fire Punch
            level: 10,
            experience_to_next_level: 1000
        };

        let opponent_red = Player {
            player_id: 2,
            player_name: 'Red',
            beast_1: 2, // Beast 1 assigned
            beast_2: 0, // No beast assigned
            beast_3: 0, // No beast assigned
            beast_4: 0, // No beast assigned
            potions: 2
        };

        let beast_2 = Beast {
            beast_id: 2,
            beast_name: 'Aqua',
            beast_type: WorldElements::Crystal(()),
            beast_description: 'A water beast',
            player_id: 2,
            hp: 5,
            current_hp: 5,
            attack: 1,
            defense: 1,
            mt1: 5, // Water Gun
            mt2: 6, // Bubble
            mt3: 7, // Aqua Tail
            mt4: 8, // Hydro Pump
            level: 5,
            experience_to_next_level: 1000
        };

        let potion = Potion {
            potion_id: 1,
            potion_name: 'Restore everything',
            potion_effect: 1
        };

        set!(world,(player_ash));

        set!(world,(opponent_red));

        set!(world, (beast_1));

        set!(world, (beast_2));

        set!(world, (potion));
        
        let _ = battle_system.init_battle(player_ash.player_id, opponent_red.player_id);

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
            beast_1: 2, // Beast 1 assigned
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
        assert!(battle.active_beast_opponent == 2, "Wrong oppponent beast id");
        assert!(battle.battle_active == 1, "Wrong active state");
        assert!(battle.turn == 0, "Wrong turn");    
    }

    #[test]
    fn test_battle() {
        let (world, battle_system) = setup_battle();

        let battle = get!(world, 1, (Battle));
        let battle_id = battle.battle_id;
        let player_beast = get!(world, battle.active_beast_player, (Beast));
        let opponent_beast = get!(world, battle.active_beast_opponent, (Beast));
        let mt_player_beast_id = player_beast.mt1;
        let mt_player_beast = get!(world, mt_player_beast_id,(Mt));
        let damage = battle_system.calculate_damage(mt_player_beast, player_beast, opponent_beast);
        

        // attack 
        battle_system.attack(battle_id, mt_player_beast_id);
        assert!(player_beast.hp == player_beast.hp - damage, "Wrong player beast health");
        assert!(opponent_beast.hp == opponent_beast.hp - damage, "Wrong opponent beast health");
    
        // use potion
        let potion_id = 1;
        battle_system.use_potion(battle_id, potion_id);
        assert!(player_beast.hp == 10, "Wrong beast health after potion");

        // flee
        battle_system.flee(battle_id);
        println!("status in test: {}", battle.battle_active);
        assert!(battle.battle_active == 0, "Wrong battle status");
    }

    #[test]
    fn test_setup() {
        let (_, _,) = setup_world();
        let (_, _,) = setup_battle();
    }
}