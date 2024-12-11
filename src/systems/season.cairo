use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use bytebeasts::{models::{season::Season}};

#[dojo::interface]
trait ISeasonAction {
    fn create_season(
        ref world: IWorldDispatcher,
        season_id: u64,
        name: felt252,
        start_date: u64,
        end_date: u64,
        is_active: bool,
        active_players: Array<u64>
    );
    fn update_season(
        ref world: IWorldDispatcher,
        season_id: u64,
        new_name: Option<felt252>,
        new_start_date: Option<u64>,
        new_end_date: Option<u64>,
        new_is_active: Option<bool>
    );
    fn add_player_to_season(
        ref world: IWorldDispatcher,
        season_id: u64,
        player_id: u64
    );
    fn delete_season(ref world: IWorldDispatcher, season_id: u64);
    fn get_season(world: @IWorldDispatcher, season_id: u64) -> Season;

    // fn get_active_seasons(world: @IWorldDispatcher) -> Array<Season>;
}

#[dojo::contract]
mod season_system {
    use super::ISeasonAction;

    use bytebeasts::{
        models::{season::Season},
    };

    #[abi(embed_v0)]
    impl SeasonActionImpl of ISeasonAction<ContractState> {

        fn create_season(
            ref world: IWorldDispatcher,
            season_id: u64,
            name: felt252,
            start_date: u64,
            end_date: u64,
            is_active: bool,
            active_players: Array<u64>
        ) {
            let season = Season {
                season_id: season_id,
                name: name,
                start_date: start_date,
                end_date: end_date,
                is_active: is_active,
                active_players: active_players
            };
            set!(world, (season))
        }

        fn update_season(
            ref world: IWorldDispatcher,
            season_id: u64,
            new_name: Option<felt252>,
            new_start_date: Option<u64>,
            new_end_date: Option<u64>,
            new_is_active: Option<bool>
        ) {
            let mut season = get!(world, season_id, (Season));

            if new_name.is_some() {
                season.name = new_name.unwrap();
            }
            if new_start_date.is_some() {
                season.start_date = new_start_date.unwrap();
            }
            if new_end_date.is_some() {
                season.end_date = new_end_date.unwrap();
            }
            if new_is_active.is_some() {
                season.is_active = new_is_active.unwrap();
            }

            set!(world, (season));
        }

        fn add_player_to_season(
            ref world: IWorldDispatcher,
            season_id: u64,
            player_id: u64
        ) {
            let mut season = get!(world, season_id, (Season));

            assert!(season.is_active, "Season is not active");

            let mut player_exists = false;
            let mut i = 0;
            while i < season.active_players.len() {
                if *season.active_players.at(i) == player_id {
                    player_exists = true;
                    break;
                }
                i += 1;
            };

            assert!(!player_exists, "Player already in season");

            season.active_players.append(player_id);
            set!(world, (season));
        }

        fn delete_season(ref world: IWorldDispatcher, season_id: u64) {
            let mut season = get!(world, season_id, (Season));

            assert!(season.is_active, "Season not found or already inactive");

            season.is_active = false;

            set!(world, (season));            
        }

        fn get_season(world: @IWorldDispatcher, season_id: u64) -> Season {
            let season_from_world = get!(world, season_id, (Season));
            season_from_world
        }

    }
}
