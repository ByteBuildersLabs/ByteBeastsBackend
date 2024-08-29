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