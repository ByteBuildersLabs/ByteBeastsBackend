// Defines the `Battle` Model, which represents a battle between two players.
// Includes various fields to track the state and progress of the battle.
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Battle {
    // Unique identifier for the battle.
    #[key]
    pub battle_id: u32,
    
    // ID of the player involved in the battle.
    pub player_id: u32,
    
    // ID of the opponent involved in the battle.
    pub opponent_id: u32,
    
    // ID of the active beast for the player.
    pub active_beast_player: u32,
    
    // ID of the active beast for the opponent.
    pub active_beast_opponent: u32,
    
    // Flag to indicate if the battle is currently active (1 for active, 0 for inactive).
    pub battle_active: u32,
    
    // Current turn number in the battle.
    pub turn: u32,
}



#[cfg(test)]
mod tests {

    use bytebeasts::{models::{battle::Battle},};

   

    #[test]
    fn test_battle_initialization() {
        let battle = Battle {
            battle_id: 1,
            player_id: 1,
            opponent_id: 2,
            active_beast_player: 1,
            active_beast_opponent: 2,
            battle_active: 1,
            turn: 1,
        };

        assert_eq!(battle.battle_id, 1, "Battle ID should be 1");
        assert_eq!(battle.player_id, 1, "Player ID should be 1");
        assert_eq!(battle.opponent_id, 2, "Opponent ID should be 2");
        assert_eq!(battle.battle_active, 1, "Battle should be active");
        assert_eq!(battle.turn, 1, "Turn should be 1");
    }
}
