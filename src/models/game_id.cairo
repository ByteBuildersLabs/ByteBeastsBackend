#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct GameId {
    #[key]
    pub id: u32,
    pub game_id: u128
}
