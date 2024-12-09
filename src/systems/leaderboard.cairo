use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use bytebeasts::models::leaderboard::{Leaderboard, LeaderboardEntry, LeaderboardTrait};
use alexandria_data_structures::array_ext::ArrayTraitExt;

#[dojo::interface]
trait ILeaderboardAction {
    fn create_leaderboard(
        ref world: IWorldDispatcher,
        leaderboard_id: u64,
        name: felt252,
        description: felt252,
        last_updated: u64,
    );

    fn add_entry(
        ref world: IWorldDispatcher,
        leaderboard_id: u64,
        player_id: u32,
        player_name: felt252,
        score: u32,
        wins: u32,
        losses: u32,
        highest_score: u32,
        is_active: bool,
    );

    fn get_all_entries(ref world: IWorldDispatcher, leaderboard_id: u64) -> Array<LeaderboardEntry>;

    fn remove_entry(ref world: IWorldDispatcher, leaderboard_id: u64, player_id: u32);

    fn update_entry(
        ref world: IWorldDispatcher,
        leaderboard_id: u64,
        player_id: u32,
        player_name: felt252,
        score: u32,
        wins: u32,
        losses: u32,
        highest_score: u32,
        is_active: bool,
    );

    fn calculate_score(wins: u32, highest_score: u32, losses: u32) -> u32;

    fn get_slice(
        ref world: IWorldDispatcher,
        leaderboard_id: u64,
        start: u32,
        end: u32,
    ) -> Array<LeaderboardEntry>;

    fn upgrade_entry_stats(
        ref world: IWorldDispatcher,
        leaderboard_id: u64,
        player_id: u32,
        new_wins: u32,
        new_losses: u32,
        new_highest_score: u32,
    );
}

#[dojo::contract]
mod leaderboard_system {
    use super::ILeaderboardAction;
    use bytebeasts::models::leaderboard::{Leaderboard, LeaderboardEntry, LeaderboardTrait};

    #[abi(embed_v0)]
    impl LeaderboardActionImpl of ILeaderboardAction<ContractState> {
        fn create_leaderboard(
            ref world: IWorldDispatcher,
            leaderboard_id: u64,
            name: felt252,
            description: felt252,
            last_updated: u64,
        ) {
            let leaderboard = Leaderboard {
                leaderboard_id,
                name,
                description,
                entries: array![],
                last_updated,
            };
            set!(world, (leaderboard));
        }

        fn add_entry(
            ref world: IWorldDispatcher,
            leaderboard_id: u64,
            player_id: u32,
            player_name: felt252,
            score: u32,
            wins: u32,
            losses: u32,
            highest_score: u32,
            is_active: bool,
        ) {
            let mut leaderboard = get!(world, leaderboard_id, Leaderboard);
            let entry = LeaderboardEntry {
                player_id,
                player_name,
                score,
                wins,
                losses,
                highest_score,
                is_active,
            };
            leaderboard.add_entry(entry).unwrap();
            set!(world, (leaderboard));
        }

        fn get_all_entries(ref world: IWorldDispatcher, leaderboard_id: u64) -> Array<LeaderboardEntry> {
            let mut leaderboard = get!(world, leaderboard_id, Leaderboard);
            leaderboard.get_entries()
        }

        fn remove_entry(ref world: IWorldDispatcher, leaderboard_id: u64, player_id: u32) {
            let mut leaderboard = get!(world, leaderboard_id, Leaderboard);
            let index = leaderboard.get_index_by_player_id(player_id).unwrap();
            let entry = leaderboard.entries.at(index);
            leaderboard.remove_entry(*entry).unwrap();
            set!(world, (leaderboard));
        }

        fn update_entry(
            ref world: IWorldDispatcher,
            leaderboard_id: u64,
            player_id: u32,
            player_name: felt252,
            score: u32,
            wins: u32,
            losses: u32,
            highest_score: u32,
            is_active: bool,
        ) {
            let mut leaderboard = get!(world, leaderboard_id, Leaderboard);
            let entry = LeaderboardEntry {
                player_id,
                player_name,
                score,
                wins,
                losses,
                highest_score,
                is_active,
            };
            leaderboard.update_entry(entry).unwrap();
            set!(world, (leaderboard));
        }

        fn calculate_score(wins: u32, highest_score: u32, losses: u32) -> u32 {
            wins * 100 + highest_score - losses * 70
        }

        fn get_slice(
            ref world: IWorldDispatcher,
            leaderboard_id: u64,
            start: u32,
            end: u32,
        ) -> Array<LeaderboardEntry> {
            let mut leaderboard = get!(world, leaderboard_id, Leaderboard);
            leaderboard.get_slice(start, end).unwrap()
        }

        fn upgrade_entry_stats(
            ref world: IWorldDispatcher,
            leaderboard_id: u64,
            player_id: u32,
            new_wins: u32,
            new_losses: u32,
            new_highest_score: u32,
        ) {
            let mut leaderboard = get!(world, leaderboard_id, Leaderboard);
            leaderboard
                .upgrade_entry_stats(player_id, new_wins, new_losses, new_highest_score)
                .unwrap();
            set!(world, (leaderboard));
        }
    }
}
