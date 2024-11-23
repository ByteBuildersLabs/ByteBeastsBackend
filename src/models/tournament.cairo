use super::player::Player;

#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
pub enum TournamentStatus {
    Pending,
    Ongoing,
    Completed,
}


#[derive(Drop, Serde)]
#[dojo::model]
pub struct Tournament {
    #[key]
    pub tournament_id: u32,
    pub name: felt252,
    pub status: TournamentStatus,
    pub entry_fee: u32,
    pub max_participants: u32,
    pub current_participants: Array<Player>,
    pub prize_pool: u32,
}

