#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug)]
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
    pub current_participants: Array<u32>,
    pub prize_pool: u32,
}


#[cfg(test)]
mod tests {
    use bytebeasts::{
        models::{tournament::Tournament, tournament::TournamentStatus}
    };


    #[test]
    fn test_tournament_initialization() {
        let tournament = Tournament {
            tournament_id: 1,
            name: 'gersonwashere',
            status: TournamentStatus::Pending,
            entry_fee: 1,
            max_participants: 2,
            current_participants: array![1],
            prize_pool: 1,
        };

        assert_eq!(tournament.tournament_id, 1, "Tournament ID should be 1");
        assert_eq!(tournament.name, 'gersonwashere', "Tournament name should be gersonwashere");
        assert_eq!(
            tournament.status, TournamentStatus::Pending, "Tournament status should be pending"
        );
        assert_eq!(tournament.entry_fee, 1, "Tournament entry fee should be 1");
        assert_eq!(tournament.max_participants, 2, "Tournament max participants should be 2");
        assert_eq!(
            tournament.current_participants.len(), 1, "Tournament current participants should be 1"
        );
        assert_eq!(tournament.prize_pool, 1, "Tournament prize pool should be 1");
    }
}

