#[cfg(test)]
mod tests {
    use starknet::ContractAddress;

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::utils::test::{spawn_test_world, deploy_contract};

    use bytebeasts::{
        systems::{
            tournament::{
                tournament_system, ITournamentActionDispatcher, ITournamentActionDispatcherTrait
            }
        },
    };

    use bytebeasts::{
        models::tournament::{{Tournament, tournament}}, models::tournament::TournamentStatus,
        models::player::{{Player, player}},
    };


    // Helper function
    // This function create the world and define the required models
    #[test]
    fn setup_world() -> (IWorldDispatcher, ITournamentActionDispatcher) {
        let mut models = array![tournament::TEST_CLASS_HASH];

        let world = spawn_test_world("bytebeasts", models);

        let contract_address = world
            .deploy_contract('salt', tournament_system::TEST_CLASS_HASH.try_into().unwrap());

        let tournament_system = ITournamentActionDispatcher { contract_address };

        world.grant_writer(dojo::utils::bytearray_hash(@"bytebeasts"), contract_address);

        (world, tournament_system)
    }

    #[test]
    fn test_create_tournament() {
        let (_, tournament_system) = setup_world();
        let mut players = ArrayTrait::new();

        let player_ash = Player {
            player_id: 1,
            player_name: 'Ash',
            beast_1: 1, // Beast 1 assigned
            beast_2: 0, // No beast assigned
            beast_3: 0, // No beast assigned
            beast_4: 0, // No beast assigned
            potions: 1
        };
        players.append(player_ash);

        tournament_system
            .create_tournament(1, 'tournament', TournamentStatus::Pending, 1, 2, players, 1);
        let tournament = tournament_system.get_tournament(1);
        assert!(tournament.name == 'tournament', "The tournament name is wrong!");
    }
}
