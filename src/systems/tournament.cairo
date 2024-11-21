use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use bytebeasts::{
    models::{player::Player, tournament::Tournament, tournament::TournamentStatus},
};

#[dojo::interface]
trait ITournamentAction {
    fn create_tournament(ref world: IWorldDispatcher, tournament_id: u32, name: felt252,
        status: TournamentStatus,
        entry_fee: u32,
        max_participants: u32,
        current_participants: Array<Player>,
        prize_pool: u32) -> Tournament;
    fn register_player(ref world: IWorldDispatcher, tournament_id: u32, player_id: u32);
    fn start_tournament(ref world: IWorldDispatcher, tournament_id: u32, player_id: u32);
    fn complete_torunament(ref world: IWorldDispatcher, tournament_id: u32, player_id: u32);
    fn get_tournament(ref world: IWorldDispatcher, tournament_id: u32) -> Tournament;
}


#[dojo::contract]
mod spawn_action {
    use super::ITournamentAction;
    use bytebeasts::{
        models::{player::Player, tournament::Tournament},
    };

    #[abi(embed_v0)]
    impl TournamentActionImpl of ITournamentAction<ContractState> {
        fn get_tournament(world: @IWorldDispatcher, tournament_id: u32) -> Tournament {
            let tournament_from_world = get!(world, tournament_id, (Tournament));
            tournament_from_world
        }
    }
}