use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use bytebeasts::{models::{player::Player, tournament::Tournament, tournament::TournamentStatus},};

#[dojo::interface]
trait ITournamentAction {
    fn create_tournament(
        ref world: IWorldDispatcher,
        tournament_id: u32,
        name: felt252,
        status: TournamentStatus,
        entry_fee: u32,
        max_participants: u32,
        current_participants: Array<Player>,
        prize_pool: u32
    );
    // fn register_player(ref world: IWorldDispatcher, tournament_id: u32, player_id: u32);
    // fn start_tournament(ref world: IWorldDispatcher, tournament_id: u32, player_id: u32);
    // fn complete_torunament(ref world: IWorldDispatcher, tournament_id: u32, player_id: u32);
    fn get_tournament(world: @IWorldDispatcher, tournament_id: u32) -> Tournament;
}


#[dojo::contract]
mod tournament_system {
    use super::ITournamentAction;
    use bytebeasts::{
        models::{player::Player, tournament::Tournament, tournament::TournamentStatus},
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
            current_participants: Array<Player>,
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

        fn get_tournament(world: @IWorldDispatcher, tournament_id: u32) -> Tournament {
            let tournament_from_world = get!(world, tournament_id, (Tournament));
            tournament_from_world
        }
    }
}
