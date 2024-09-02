#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Battle {
    #[key]
    pub battle_id: u32,
    pub player_id: u32,
    pub opponent_id: u32,
    pub active_beast_player: u32,
    pub active_beast_opponent: u32,
    pub battle_active: u32,
    pub turn: u32,
}

#[cfg(test)]
mod tests {
    use bytebeasts::models::battle::Battle;

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
