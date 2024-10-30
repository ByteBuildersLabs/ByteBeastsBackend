
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


    // Initializes the testing environment by creating the world with the required models and deploying the battle contract.
    #[test]
     fn setup_world() -> (IWorldDispatcher, IBattleActionsDispatcher) {
        let mut models = array![
            beast::TEST_CLASS_HASH,
            mt::TEST_CLASS_HASH,
            player::TEST_CLASS_HASH,
            potion::TEST_CLASS_HASH,
            battle::TEST_CLASS_HASH,
            
        ];
        
        // Spawns a test world with the specified name and models
        let world = spawn_test_world("bytebeasts", models);
 
        // Deploys the battle system contract and retrieves its address
        let contract_address = world.deploy_contract('salt', battle_system::TEST_CLASS_HASH.try_into().unwrap());

        // Initializes the battle system dispatcher with the deployed contract address
        let battle_system = IBattleActionsDispatcher { contract_address };

        // Grants write permissions for the battle system contract
        world.grant_writer(dojo::utils::bytearray_hash(@"bytebeasts"), contract_address);
 
        // Returns the world instance and battle system dispatcher
        (world, battle_system)
    }


    // Initializes a battle setup with two players and their beasts, as well as moves and a potion.
    #[test]
    fn setup_battle() -> (IWorldDispatcher, IBattleActionsDispatcher) {
        let (world, battle_system) = setup_world();

        // Define Player 1 (Ash) and his beast (Firebeast)
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
            hp: 200,
            current_hp: 200,
            attack: 7,
            defense: 7,
            mt1: 1, // Move: Fire Blast
            mt2: 2, // Move: Ember
            mt3: 3, // Move: Flame Wheel
            mt4: 4, // Move: Fire Punch
            level: 10,
            experience_to_next_level: 1000
        };

        // Define Player 2 (Red) and his beast (Aqua)
        let opponent_red = Player {
            player_id: 2,
            player_name: 'Red',
            beast_1: 2, // Beast 2 assigned
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
            hp: 200,
            current_hp: 200,
            attack: 5,
            defense: 5,
            mt1: 8, // Move: Hydro Pump
            mt2: 6, // Move: Bubble
            mt3: 7, // Move: Aqua Tail
            mt4: 5, // Move: Water Gun
            level: 5,
            experience_to_next_level: 1000
        };

        // Define a potion to be used in the battle
        let potion = Potion {
            potion_id: 1,
            potion_name: 'Restore everything',
            potion_effect: 250
        };

         // Set moves (Mts) in the world
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
                mt_power: 500,
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

        // Register players, beasts, and potion in the world
        set!(world,(player_ash));

        set!(world,(opponent_red));

        set!(world, (beast_1));

        set!(world, (beast_2));

        set!(world, (potion));
        
        // Initialize the battle between the two players
        let _ = battle_system.init_battle(player_ash.player_id, opponent_red.player_id);

        (world, battle_system)
    }


    // This test verifies the initialization of a battle between two players.
    #[test]
    fn test_init_battle() {
        // Setup world and battle system
        let (world, battle_system) = setup_world();

        // Define Player 1 (Ash) with a single beast
        let player_ash = Player {
            player_id: 1,
            player_name: 'Ash',
            beast_1: 1, // Beast 1 assigned
            beast_2: 0, // No beast assigned
            beast_3: 0, // No beast assigned
            beast_4: 0, // No beast assigned
            potions: 2
        };

        // Define Player 2 (Red) with a single beast
        let opponent_red = Player {
            player_id: 2,
            player_name: 'Red',
            beast_1: 2, // Beast 2 assigned
            beast_2: 0, // No beast assigned
            beast_3: 0, // No beast assigned
            beast_4: 0, // No beast assigned
            potions: 2
        };

        // Register players in the world
        set!(world,(player_ash));
        set!(world,(opponent_red));

        // Initialize battle between Ash and Red
        let battle_id = battle_system.init_battle(player_ash.player_id, opponent_red.player_id);

        // Retrieve battle data and validate initialization values
        let battle = get!(world, battle_id,(Battle));

        assert!(battle.battle_id == 1, "Wrong battle id");
        assert!(battle.player_id == 1, "Wrong player id");
        assert!(battle.opponent_id == 2, "Wrong opponent id");
        assert!(battle.active_beast_player == 1, "Wrong player beast id");
        assert!(battle.active_beast_opponent == 2, "Wrong oppponent beast id");
        assert!(battle.battle_active == 1, "Wrong active state");
        assert!(battle.turn == 0, "Wrong turn");    
    }

   
    // This test simulates a full battle scenario where the player wins.
    #[test]
    fn test_battle_player_wins() {
        println!("-> Battle Started!");

        // Initialize the battle setup with a predefined player and opponent
        let (world, battle_system) = setup_battle();
        let battle_id = 1;

        // Retrieve initial battle and beast states
        let mut battle = get!(world, battle_id, (Battle));
        let mut player_beast = get!(world, battle.active_beast_player, (Beast));
        let mut opponent_beast = get!(world, battle.active_beast_opponent, (Beast));

        // Display initial health points for clarity
        println!("-> Player beast: {}", player_beast.beast_name);
        println!("-> Health points: {}", player_beast.hp);
        
        println!("-> Opponent beast: {}", opponent_beast.beast_name);
        println!("-> Health points: {}", opponent_beast.hp);
        
        // Retrieve move (MT) for both player and opponent beasts
        let mt_player_beast_id = player_beast.mt1;
        let mt_player_beast = get!(world, mt_player_beast_id, (Mt));

        let mt_opponent_beast_id = opponent_beast.mt1;
        let mt_opponent_beast = get!(world, mt_opponent_beast_id, (Mt));
        
        // Calculate damage for initial attacks from both sides
        let player_beast_damage = battle_system.calculate_damage(mt_player_beast, player_beast, opponent_beast);
        let opponent_beast_damage = battle_system.calculate_damage(mt_opponent_beast, opponent_beast, player_beast);

        // Player's turn to attack
        battle_system.attack(battle_id, mt_player_beast_id);
        opponent_beast = get!(world, battle.active_beast_opponent, (Beast));
        assert!(opponent_beast.current_hp == opponent_beast.hp - player_beast_damage, "Wrong opponent beast health");
        println!("-> Player has performed an attack with MT: {}", mt_player_beast.mt_name);
        println!("-> Opponent beast health points: {}", opponent_beast.current_hp);
        
        // Opponent's turn to attack
        battle_system.opponent_turn(battle_id);
        player_beast = get!(world, battle.active_beast_player, (Beast));   
        assert!(player_beast.current_hp == player_beast.hp - opponent_beast_damage, "Wrong player beast health");
        println!("-> Opponent has performed an attack with MT: {}", mt_opponent_beast.mt_name);
        println!("-> Player beast health points: {}", player_beast.current_hp);
        
       // Player uses a potion to restore health
        let potion_id = 1;
        let potion = get!(world, potion_id, (Potion));
        battle_system.use_potion(battle_id, potion_id);
        player_beast = get!(world, battle.active_beast_player, (Beast));
        assert!(player_beast.current_hp == 200, "Wrong beast health after potion");
        println!("-> Player used a {} potion", potion.potion_name);
        println!("-> Player beast health points after potion: {}", player_beast.current_hp);

        // Final attack with a powerful move, knocking out the opponent
        battle_system.attack(battle_id, 4);
        opponent_beast = get!(world, battle.active_beast_opponent, (Beast));
        assert!(opponent_beast.current_hp == 0, "Wrong opponent beast health");
        println!("-> Player has performed an attack with MT: {}", mt_player_beast.mt_name);
        println!("-> Opponent beast health points: {}", opponent_beast.current_hp);
        println!("-> Player wins the battle!");
        
       // Verify that the battle is no longer active
        battle = get!(world, battle_id, (Battle));
        assert!(battle.battle_active == 0, "Wrong battle status");
    }

    // This test simulates a battle scenario where the opponent wins.
    #[test]
    fn test_battle_opponent_wins() {
        // Initialize the battle with a predefined player and opponent
        let (world, battle_system) = setup_battle();
        let battle_id = 1;

        // Retrieve initial battle and beast states
        let mut battle = get!(world, battle_id, (Battle));
        let mut player_beast = get!(world, battle.active_beast_player, (Beast));
        let mut opponent_beast = get!(world, battle.active_beast_opponent, (Beast));
        
        // Retrieve and calculate damage for player’s initial attack
        let mt_player_beast_id = player_beast.mt1;
        let mt_player_beast = get!(world, mt_player_beast_id, (Mt));
        let player_beast_damage = battle_system.calculate_damage(mt_player_beast, player_beast, opponent_beast);

        // Player attacks the opponent
        battle_system.attack(battle_id, mt_player_beast_id);
        opponent_beast = get!(world, battle.active_beast_opponent, (Beast));
        assert!(opponent_beast.current_hp == opponent_beast.hp - player_beast_damage, "Wrong opponent beast health");
        
        // Final attack with a powerful move, knocking out the opponent
        let mut mt_opponent_beast = get!(world, 8, (Mt)); // Opponent always attack with mt1
        mt_opponent_beast.mt_power = 500;
        set!(world,(mt_opponent_beast));

        // Opponent's turn to attack
        battle_system.opponent_turn(battle_id);
        player_beast = get!(world, battle.active_beast_player, (Beast)); 
        assert!(player_beast.current_hp == 0, "Wrong player beast health");

        // Verify that the battle is no longer active
        battle = get!(world, battle_id, (Battle));
        assert!(battle.battle_active == 0, "Wrong battle status");
    }


    // This test simulates the scenario where the player attempts to flee the battle.
    #[test]
    fn test_flee() {
        // Initialize the battle setup
        let (world, battle_system) = setup_battle();
        let battle_id = 1;

        // Attempt to flee
        battle_system.flee(battle_id);
        let battle = get!(world, battle_id, (Battle));
        assert!(battle.battle_active == 0, "Wrong battle status");
    }


    // Verifies that the setup functions execute correctly.
    #[test]
    fn test_setup() {
        let (_, _,) = setup_world();
        let (_, _,) = setup_battle();
    }
}