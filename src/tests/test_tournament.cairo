#[cfg(test)]
mod tests {
    use starknet::ContractAddress;

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait}; 
    use dojo::utils::test::{spawn_test_world, deploy_contract};

    use bytebeasts::{
        systems::{tournament::{tournament_system, ITournamentActionDispatcher, ITournamentActionDispatcherTrait}}
    };

    use bytebeasts::{
        models::player::{Player, player},
        models::tournament::{Tournament, tournament, TournamentStatus},
    };

    const TOURNAMENT_ID: u32 = 1;
    const TOURNAMENT_NAME: felt252 = 'TOURNAMENT_NAME';
    const TOURNAMENT_ENTRY_FEE: u32 = 0;
    const TOURNAMENT_MAX_PARTICIPANTS: u32 = 2;
    const TOURNAMENT_PRIZE_POOL: u32 = 0;

    const PLAYER1_ID: u32 = 1;
    const PLAYER1_NAME: felt252 = 'PLAYER1';
    const PLAYER1_BEAST1: u32 = 0;
    const PLAYER1_BEAST2: u32 = 0;
    const PLAYER1_BEAST3: u32 = 0;
    const PLAYER1_BEAST4: u32 = 0;
    const PLAYER1_POTIONS: u32 = 0;

    // Helper function to create the first player
    fn get_player1() -> Player {
        Player {
            player_id: PLAYER1_ID,
            player_name: PLAYER1_NAME,
            beast_1: PLAYER1_BEAST1,
            beast_2: PLAYER1_BEAST2,
            beast_3: PLAYER1_BEAST3,
            beast_4: PLAYER1_BEAST4,
            potions: PLAYER1_POTIONS
        }
    }

    const PLAYER2_ID: u32 = 2;
    const PLAYER2_NAME: felt252 = 'PLAYER2';
    const PLAYER2_BEAST1: u32 = 0;
    const PLAYER2_BEAST2: u32 = 0;
    const PLAYER2_BEAST3: u32 = 0;
    const PLAYER2_BEAST4: u32 = 0;
    const PLAYER2_POTIONS: u32 = 0;

    // Helper function to create the second player
    fn get_player2() -> Player {
        Player {
            player_id: PLAYER2_ID,
            player_name: PLAYER2_NAME,
            beast_1: PLAYER2_BEAST1,
            beast_2: PLAYER2_BEAST2,
            beast_3: PLAYER2_BEAST3,
            beast_4: PLAYER2_BEAST4,
            potions: PLAYER2_POTIONS
        }
    }

    const PLAYER3_ID: u32 = 3;
    const PLAYER3_NAME: felt252 = 'PLAYER3';
    const PLAYER3_BEAST1: u32 = 0;
    const PLAYER3_BEAST2: u32 = 0;
    const PLAYER3_BEAST3: u32 = 0;
    const PLAYER3_BEAST4: u32 = 0;
    const PLAYER3_POTIONS: u32 = 0;

    // Helper function to create the third player
    fn get_player3() -> Player {
        Player {
            player_id: PLAYER3_ID,
            player_name: PLAYER3_NAME,
            beast_1: PLAYER3_BEAST1,
            beast_2: PLAYER3_BEAST2,
            beast_3: PLAYER3_BEAST3,
            beast_4: PLAYER3_BEAST4,
            potions: PLAYER3_POTIONS
        }
    }

    // Initializes the testing environment by creating the world with the required models and deploying the tournament contract
    fn setup_world() -> (IWorldDispatcher, ITournamentActionDispatcher) {
        let mut models = array![
            player::TEST_CLASS_HASH,
            tournament::TEST_CLASS_HASH
        ];
        
        // Spawns a test world with the specified name and models
        let world = spawn_test_world("bytebeasts", models);
 
        // Deploys the tournament system contract and retrieves its address
        let contract_address = world.deploy_contract('salt', tournament_system::TEST_CLASS_HASH.try_into().unwrap());

        // Initializes the tournament system dispatcher with the deployed contract address
        let tournament_system = ITournamentActionDispatcher { contract_address };

        // Grants write permissions for the tournament system contract
        world.grant_writer(dojo::utils::bytearray_hash(@"bytebeasts"), contract_address);
 
        // Returns the world instance and tournament system dispatcher
        (world, tournament_system)
    }

    // Initializes an empty tournament
    fn setup_tournament() -> (IWorldDispatcher, ITournamentActionDispatcher) {
        let (world, tournament_system) = setup_world();

        // Creates an empty pending tournament with no participants
        tournament_system.create_tournament(
            TOURNAMENT_ID,
            TOURNAMENT_NAME,
            TournamentStatus::Pending,
            TOURNAMENT_ENTRY_FEE,
            TOURNAMENT_MAX_PARTICIPANTS,
            array![],
            TOURNAMENT_PRIZE_POOL
        );

        (world, tournament_system)
    }

    // Initializes a tournament with 2 players
    fn setup_tournament_with_players() -> (IWorldDispatcher, ITournamentActionDispatcher) {
        let (world, tournament_system) = setup_world();

        // Creates the 2 players
        let player1 = get_player1();
        set!(world, (player1));
        let player2 = get_player2();
        set!(world, (player2));

        // Creates a tournament with 2 participants
        tournament_system.create_tournament(
            TOURNAMENT_ID,
            TOURNAMENT_NAME,
            TournamentStatus::Pending,
            TOURNAMENT_ENTRY_FEE,
            TOURNAMENT_MAX_PARTICIPANTS,
            array![player1.player_id, player2.player_id],
            TOURNAMENT_PRIZE_POOL
        );

        (world, tournament_system)
    }

    // This test verifies the creation of an empty tournament
    #[test]
    fn test_create_tournament() {
        let (world, _) = setup_tournament();

        let tournament = get!(world, TOURNAMENT_ID, (Tournament));

        assert_eq!(tournament.tournament_id, TOURNAMENT_ID);
        assert_eq!(tournament.name, TOURNAMENT_NAME);
        assert_eq!(tournament.status, TournamentStatus::Pending);
        assert_eq!(tournament.entry_fee, TOURNAMENT_ENTRY_FEE);
        assert_eq!(tournament.max_participants, TOURNAMENT_MAX_PARTICIPANTS);
        assert_eq!(tournament.current_participants, array![]);
        assert_eq!(tournament.prize_pool, TOURNAMENT_PRIZE_POOL);
    }

    // This test verifies the creation of a tournament with 2 players
    #[test]
    fn test_create_tournament_with_players() {
        let (world, _) = setup_tournament_with_players();

        let tournament = get!(world, TOURNAMENT_ID, (Tournament));

        assert_eq!(tournament.tournament_id, TOURNAMENT_ID);
        assert_eq!(tournament.name, TOURNAMENT_NAME);
        assert_eq!(tournament.status, TournamentStatus::Pending);
        assert_eq!(tournament.entry_fee, TOURNAMENT_ENTRY_FEE);
        assert_eq!(tournament.max_participants, TOURNAMENT_MAX_PARTICIPANTS);
        assert_eq!(tournament.current_participants, array![PLAYER1_ID, PLAYER2_ID]);
        assert_eq!(tournament.prize_pool, TOURNAMENT_PRIZE_POOL);
    }

    // This test verifies a player can't be registered if the tournament status is not pending
    #[test]
    #[should_panic(expected: ("Tournament not open for registration", 'ENTRYPOINT_FAILED'))]
    fn test_register_player_not_pending() {
        let (world, tournament_system) = setup_tournament();

        // Mutates the status to ongoing to make player registration fail
        let mut tournament = get!(world, TOURNAMENT_ID, (Tournament));
        tournament.status = TournamentStatus::Ongoing;
        set!(world, (tournament));

        let player1 = get_player1();
        set!(world, (player1));

        tournament_system.register_player(TOURNAMENT_ID, player1.player_id);
    }

    // This test verifies it's impossible for a player to join an already full tournament
    #[test]
    #[should_panic(expected: ("Tournament is full", 'ENTRYPOINT_FAILED'))]
    fn test_register_player_tournament_full() {
        let (world, tournament_system) = setup_tournament_with_players();

        let player3 = get_player3();
        set!(world, (player3));

        tournament_system.register_player(TOURNAMENT_ID, player3.player_id);
    }

    // This test verifies the tournament can register players
    #[test]
    fn test_register_players() {
        let (world, tournament_system) = setup_tournament();

        let player1 = get_player1();
        set!(world, (player1));
        tournament_system.register_player(TOURNAMENT_ID, player1.player_id);
        let tournament = get!(world, TOURNAMENT_ID, (Tournament));
        assert_eq!(tournament.current_participants, array![player1.player_id]);

        let player2 = get_player2();
        set!(world, (player2));
        tournament_system.register_player(TOURNAMENT_ID, player2.player_id);
        let tournament = get!(world, TOURNAMENT_ID, (Tournament));
        assert_eq!(tournament.current_participants, array![player1.player_id, player2.player_id]);
    }

    // This test verifies the tournament cannot be started if not in the pending status
    #[test]
    #[should_panic(expected: ("Tournament not pending", 'ENTRYPOINT_FAILED'))]
    fn test_start_tournament_not_pending() {
        let (world, tournament_system) = setup_tournament();

        // Mutates the status to ongoing so that the tournament will fail to start
        let mut tournament = get!(world, TOURNAMENT_ID, (Tournament));
        tournament.status = TournamentStatus::Ongoing;
        set!(world, (tournament));

        tournament_system.start_tournament(TOURNAMENT_ID);
    }

    // This test verifies the tournament cannot be started until we reach at least 2 participants
    #[test]
    #[should_panic(expected: ("Not enough participants to start", 'ENTRYPOINT_FAILED'))]
    fn test_start_tournament_not_enough_participants() {
        let (_, tournament_system) = setup_tournament();

        tournament_system.start_tournament(TOURNAMENT_ID);
    }

    // This test verifies the tournament can be started correctly
    #[test]
    fn test_start_tournament() {
        let (world, tournament_system) = setup_tournament_with_players();

        tournament_system.start_tournament(TOURNAMENT_ID);

        let tournament = get!(world, TOURNAMENT_ID, (Tournament));
        assert_eq!(tournament.status, TournamentStatus::Ongoing);
    }

    // This test verifies the tournament can't be completed if not ongoing
    #[test]
    #[should_panic(expected: ("Tournament not ongoing", 'ENTRYPOINT_FAILED'))]
    fn test_complete_tournament_not_ongoing() {
        let (_, tournament_system) = setup_tournament();

        tournament_system.complete_tournament(TOURNAMENT_ID, PLAYER1_ID);
    }

    // This test verifies that the declared winner of a tournament must be a participant
    #[test]
    #[should_panic(expected: ("Winner not participant", 'ENTRYPOINT_FAILED'))]
    fn test_complete_tournament_not_participant() {
        let (_, tournament_system) = setup_tournament_with_players();

        tournament_system.start_tournament(TOURNAMENT_ID);

        tournament_system.complete_tournament(TOURNAMENT_ID, PLAYER3_ID);
    }

    // This test verifies the tournament can be completed correctly
    #[test]
    fn test_complete_tournament() {
        let (world, tournament_system) = setup_tournament_with_players();

        tournament_system.start_tournament(TOURNAMENT_ID);

        tournament_system.complete_tournament(TOURNAMENT_ID, PLAYER1_ID);

        let tournament = get!(world, TOURNAMENT_ID, (Tournament));
        assert_eq!(tournament.status, TournamentStatus::Completed);
    }

    // This test verifies the custom getter returns the same data stored in the world
    #[test]
    fn test_get_tournament() {
        let (world, tournament_system) = setup_tournament();

        let tournament_from_system = tournament_system.get_tournament(TOURNAMENT_ID);
        let tournament_from_world = get!(world, TOURNAMENT_ID, (Tournament));

        assert_eq!(tournament_from_system.tournament_id, tournament_from_world.tournament_id);
        assert_eq!(tournament_from_system.name, tournament_from_world.name);
        assert_eq!(tournament_from_system.status, tournament_from_world.status);
        assert_eq!(tournament_from_system.entry_fee, tournament_from_world.entry_fee);
        assert_eq!(tournament_from_system.max_participants, tournament_from_world.max_participants);
        assert_eq!(tournament_from_system.current_participants, tournament_from_world.current_participants);
        assert_eq!(tournament_from_system.prize_pool, tournament_from_world.prize_pool);
    }
}
