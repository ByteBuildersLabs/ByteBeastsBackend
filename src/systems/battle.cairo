// ***************************************************************
//                           IMPORTS
// ***************************************************************

// Required modules and models for the battle system.
use bytebeasts::{
    models::{beast::Beast, mt::Mt, player::Player, battle::Battle, potion::Potion},
};

// ***************************************************************
//                           INTERFACE
// ***************************************************************

/// Interface defining battle-related actions.
#[dojo::interface]
trait IBattleActions {
    fn init_battle(ref world: IWorldDispatcher, player_id: u32, opponent_id: u32) -> u32; // Initializes a battle
    fn check_flee_success(player_beast: Beast, opponent_beast: Beast) -> bool; // Checks flee success
    fn calculate_damage(mt: Mt, attacker: Beast, defender: Beast) -> u32; // Calculates damage
    fn opponent_turn(ref world: IWorldDispatcher, battle_id: u32); // Handles opponent's turn
    fn attack(ref world: IWorldDispatcher, battle_id: u32, mt_id: u32); // Executes an attack
    fn use_potion(ref world: IWorldDispatcher, battle_id: u32, potion_id: u32); // Uses a potion
    fn flee(ref world: IWorldDispatcher, battle_id: u32); // Attempts to flee
}

// ***************************************************************
//                           CONTRACT MODULE
// ***************************************************************

/// Contract implementing battle actions.
#[dojo::contract]
mod battle_system {
// ***************************************************************
//                           IMPORTS
// ***************************************************************

    use super::{IBattleActions}; 
    use bytebeasts::{
        models::{beast::Beast, mt::Mt, player::Player, battle::Battle, potion::Potion},
    };

    // ***************************************************************
    //                       EVENTS
    // ***************************************************************

    /// Event emitted for battle status updates.
    #[derive(Copy, Drop, Serde)]
    #[dojo::model]
    #[dojo::event]
    struct StatusBattle {
        #[key]
        battle_id: u32, // Battle identifier
        message: felt252, // Event message
    }

    /// Event emitted for player status updates.
    #[derive(Copy, Drop, Serde)]
    #[dojo::model]
    #[dojo::event]
    struct Status {
        #[key]
        player_id: u32, // Player identifier
        message: felt252, // Event message
    }


// ***************************************************************
//                          Battle Actions
// ***************************************************************

#[abi(embed_v0)]
impl BattleActionsImpl of IBattleActions<ContractState> {
    
    /// Initializes a new battle.
    fn init_battle(ref world: IWorldDispatcher, player_id: u32, opponent_id: u32) -> u32 {
        let player = get!(world, player_id, (Player)); // Fetch player data
        let opponent = get!(world, opponent_id, (Player)); // Fetch opponent data
        let active_beast_player = get!(world, player.beast_1, (Beast)); // Player's beast
        let active_beast_opponent = get!(world, opponent.beast_1, (Beast)); // Opponent's beast

        let battle_created_id = 1; // Temporarily hardcoded battle ID
            set!(
                world,
                (Battle {
                    battle_id: battle_created_id,
                    player_id: player_id,
                    opponent_id: opponent_id,
                    active_beast_player: active_beast_player.beast_id,
                    active_beast_opponent: active_beast_opponent.beast_id,
                    battle_active: 1,
                    turn: 0,
                })
            );

            let message = 'Battle started';
            emit!(world, (Status { player_id: player_id,  message: message })); // Emit player status

            emit!(world, (StatusBattle { battle_id: battle_created_id,  message: message })); // Emit battle status

            return battle_created_id; // Return battle ID
        }

        /// Checks if the player can flee based on beast levels.
        fn check_flee_success(player_beast: Beast, opponent_beast: Beast) -> bool {
            player_beast.level > opponent_beast.level 
        }  

         /// Calculates the damage dealt by an attacker to a defender.
        fn calculate_damage(mt: Mt, attacker: Beast, defender: Beast) -> u32 {
            let base_damage = mt.mt_power * attacker.attack / defender.defense;  // Basic damage formula

            
            let effective_damage = base_damage; // Placeholder for effectiveness adjustments

            // Hardcoded hit chance
            let hit_chance = 80_u32; // Hardcoded for now
            if hit_chance > mt.mt_accuracy {
                return 0_u32; // Misses if hit chance is greater than accuracy
            }

            effective_damage
        }


// ***************************************************************
//                        Opponent's Turn
// ***************************************************************

        /// Executes the opponent's turn in the battle.
        fn opponent_turn(ref world: IWorldDispatcher, battle_id: u32) {
            let mut battle = get!(world, battle_id, (Battle)); // Retrieve battle details

            let mut player_beast = get!(world, battle.active_beast_player, (Beast));
            let mut opponent_beast = get!(world, battle.active_beast_opponent, (Beast));
            let opponent_attack = get!(world, opponent_beast.mt1, (Mt)); // Opponent's chosen move

            // Calculate damage dealt by the opponent to the player
            let damage = self.calculate_damage(opponent_attack, opponent_beast, player_beast);
            if damage >= player_beast.current_hp {
                player_beast.current_hp = 0; // Knock out player’s beast if damage exceeds current HP
            } else {
                player_beast.current_hp -= damage; // Subtract damage from player's beast HP
            }
            set!(world, (player_beast)); // Update player's beast in the world

            // Check if the player's beast is knocked out
            if player_beast.current_hp <= 0_u32 {
                let message = 'Player Beast Knocked Out!';
                emit!(world, (StatusBattle { battle_id,  message })); // Emit battle status update
                battle.battle_active = 0; // Emit battle status update
                set!(world, (battle)); // Update battle status in the world
            }
        }

// ***************************************************************
//                           Player Attack
// ***************************************************************
        /// Executes the player's attack in the battle.
        fn attack(ref world: IWorldDispatcher, battle_id: u32, mt_id: u32) {
            let mut battle = get!(world, battle_id, (Battle)); // Retrieve battle details

            // Fetch the player's and opponent's active beasts and the chosen move (mt) of the player
            let player_beast = get!(world, battle.active_beast_player, (Beast));
            let mut opponent_beast = get!(world, battle.active_beast_opponent, (Beast));
            let mt = get!(world, mt_id, (Mt));

            // Calculate damage dealt by the player to the opponent
            let damage = self.calculate_damage(mt, player_beast, opponent_beast);

            // Apply damage to opponent's beast HP
            if damage >= opponent_beast.current_hp {
                opponent_beast.current_hp = 0; // Knock out opponent’s beast if damage exceeds current HP
            } else {
                opponent_beast.current_hp -= damage; // Subtract damage from opponent's beast HP
            }
            set!(world, (opponent_beast)); // Update opponent's beast in the world

            // Check if the opponent's beast is knocked out
            if opponent_beast.current_hp <= 0_u32 {
                let message = 'Opponent Beast Knocked Out!';
                emit!(world, (StatusBattle { battle_id,  message }));  // Emit battle status update
                battle.battle_active = 0; // End the battle
                set!(world, (battle));  // Update battle status in the world
            } else {
                let message = 'Attack Performed!';
                emit!(world, (StatusBattle { battle_id,  message })); // Emit message indicating the attack was performed
            }
            }
        }

// ***************************************************************
//                           Use Potion
// ***************************************************************
        /// Allows the player to use a potion on their beast to restore health.
        fn use_potion(ref world: IWorldDispatcher, battle_id: u32, potion_id: u32) {
            let mut battle = get!(world, battle_id, (Battle));  // Retrieve battle details

            // Fetch the player's active beast and the potion being used
            let mut player_beast = get!(world, battle.active_beast_player, (Beast));
            let potion = get!(world, potion_id, (Potion));

            // Restore health points based on potion's effect without exceeding max HP
            if potion.potion_effect <= player_beast.current_hp {
                player_beast.current_hp += potion.potion_effect; // Add potion effect to current HP
            }
            else {
                player_beast.current_hp = player_beast.hp; // Cap HP to the beast's max health
            }

            set!(world, (player_beast)); // Update the player's beast in the world
            player_beast = get!(world, battle.active_beast_player, (Beast));

            // Emit an event to notify that the potion has been used
            let message = 'Item Used!';
            emit!(world, (StatusBattle { battle_id,  message }));
        }

// ***************************************************************
//                           Flee Action
// ***************************************************************
        /// Attempts to flee the battle. Success is determined by the relative levels of the player and opponent beasts.
        fn flee(ref world: IWorldDispatcher, battle_id: u32) {
            let mut battle = get!(world, battle_id, (Battle)); // Retrieve battle details

            // Fetch both player's and opponent's active beasts
            let player_beast = get!(world, battle.active_beast_player, (Beast));
            let opponent_beast = get!(world, battle.active_beast_opponent, (Beast));

            // Determine if flee attempt is successful based on beast levels
            let flee_success = self.check_flee_success(player_beast, opponent_beast);
            if flee_success {
                battle.battle_active = 0; // Set battle as inactive upon successful flee
                set!(world, (battle)); // Update battle status in the world

                // Emit event indicating the player successfully fled the battle
                let message = 'Player Fled!';
                emit!(world, (StatusBattle { battle_id, message }));
            } else {
                 // Emit event indicating flee attempt failed
                let message = 'Flee failed!';
                emit!(world, (StatusBattle { battle_id,  message }));
            }
        }
    }
}
