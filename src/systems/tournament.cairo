use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use bytebeasts::{models::{tournament::Tournament, tournament::TournamentStatus},};

#[dojo::interface]
trait ITournamentAction {
    fn create_tournament(
        ref world: IWorldDispatcher,
        tournament_id: u32,
        name: felt252,
        status: TournamentStatus,
        entry_fee: u32,
        max_participants: u32,
        current_participants: Array<u32>,
        prize_pool: u32
    );
    fn register_player(ref world: IWorldDispatcher, tournament_id: u32, new_player_id: u32);
    fn start_tournament(ref world: IWorldDispatcher, tournament_id: u32);
    fn complete_tournament(ref world: IWorldDispatcher, tournament_id: u32, player_id: u32);
    fn get_tournament(world: @IWorldDispatcher, tournament_id: u32) -> Tournament;
}


#[dojo::contract]
mod tournament_system {
    use super::ITournamentAction;
    use bytebeasts::{
        models::{tournament::Tournament, tournament::TournamentStatus},
    };

    #[abi(embed_v0)]
    impl TournamentActionImpl of ITournamentAction<ContractState> {
        fn create_tournament(
            ref world: IWorldDispatcher,
            tournament_id: u32,
            name: felt252,
            status: TournamentStatus,
            entry_fee: u32,
            max_participants: u32,
            current_participants: Array<u32>,
            prize_pool: u32
        ) {
            let tournament = Tournament {
                tournament_id: tournament_id,
                name: name,
                status: status,
                entry_fee: entry_fee,
                max_participants: max_participants,
                current_participants: current_participants,
                prize_pool: prize_pool
            };
            set!(world, (tournament))
        }

        fn register_player(ref world: IWorldDispatcher, tournament_id: u32, new_player_id: u32) {
            let mut tournament = get!(world, tournament_id, (Tournament));
        
            assert!(tournament.status == TournamentStatus::Pending, "Tournament not open for registration");
        
            assert!(
                tournament.current_participants.len() < tournament.max_participants.try_into().unwrap(), 
                "Tournament is full"
            );

            tournament.current_participants.append(new_player_id);

            set!(world, (tournament));
        }

        fn start_tournament(ref world: IWorldDispatcher, tournament_id: u32) {
            let mut tournament = get!(world, tournament_id, (Tournament));
        
            assert!(tournament.status == TournamentStatus::Pending, "Tournament not pending");
        
            assert!(
                tournament.current_participants.len() >= 2, 
                "Not enough participants to start"
            );

            tournament.status = TournamentStatus::Ongoing;

            set!(world, (tournament));
        }

        fn complete_tournament(ref world: IWorldDispatcher, tournament_id: u32, player_id: u32) {
            let tournament = get!(world, tournament_id, (Tournament));
        
            assert!(tournament.status == TournamentStatus::Ongoing, "Tournament not ongoing");

             // Validate winner is a participant
            let mut is_participant = false;
            for participant in tournament.current_participants {
                if participant == player_id {
                    is_participant = true;
                    break;
                }
            };
            assert!(is_participant, "Winner not participant");

            // TODO distribute prize pool to winner
            let mut tournament = get!(world, tournament_id, (Tournament));
            tournament.status = TournamentStatus::Completed;

            set!(world, (tournament));
        }

        fn get_tournament(world: @IWorldDispatcher, tournament_id: u32) -> Tournament {
            let tournament_from_world = get!(world, tournament_id, (Tournament));
            tournament_from_world
        }
    }
}
