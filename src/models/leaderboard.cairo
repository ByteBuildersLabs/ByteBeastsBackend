use starknet::ContractAddress;
use alexandria_data_structures::array_ext::ArrayTraitExt;
use alexandria_searching::binary_search::binary_search;
use alexandria_sorting::merge_sort::sort;
use core::{
    result::Result,
    option::OptionTrait,
    array::ArrayTrait
};

const MAX_ENTRIES: usize = 5;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct LeaderboardEntry {
    #[key]
    pub player_id: u32,         // On-chain player address
    pub player_name: felt252,               // Display name
    pub score: u32,                         // Overall score
    pub rank: u32,                          // Rank in the leaderboard
    pub wins: u32,                          // Total wins
    pub losses: u32,                        // Total losses
    pub highest_score: u32,                 // Highest score in a single game
    pub is_active: bool,                    // Whether the player is currently active
}


impl LeaderboardEntryPartialOrd of PartialOrd<LeaderboardEntry> {
    fn le(lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> bool {
        // less than or equal
        lhs.score <= rhs.score
    }

    fn ge(lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> bool {
        // greater than or equal
        lhs.score >= rhs.score
    }

    fn lt(lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> bool {
        lhs.score < rhs.score
    }

    fn gt(lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> bool {
        lhs.score > rhs.score
    }
}

impl LeaderboardEntryPartialEq of PartialEq<LeaderboardEntry> {
    fn eq(lhs: @LeaderboardEntry, rhs: @LeaderboardEntry) -> bool {
        lhs.score == rhs.score
    }

    fn ne(lhs: @LeaderboardEntry, rhs: @LeaderboardEntry) -> bool {
        lhs.score != rhs.score
    }
}


#[derive(Drop, Serde)]
#[dojo::model]
pub struct Leaderboard {
    #[key]
    pub leaderboard_id: u64,                // Unique ID for leaderboard (could be incremental)
    pub name: felt252,                      // Leaderboard name (e.g., "Global", "Monthly")
    pub description: felt252,               // Description of what this leaderboard tracks
    pub entries: Array<LeaderboardEntry>,   // List of leaderboard entries
    pub last_updated: u64,                  // Timestamp of last update
}



trait LeaderboardBehavior {
    // implemented:
    fn add_entry(ref self: Leaderboard, entry: LeaderboardEntry) -> Result<(), felt252>;
    fn is_full(self: @Leaderboard) -> bool;
    // not implemented:
    // fn remove_entry(mut self, player_id: ContractAddress);
    // fn sort_by_score(mut self);
    // fn get_top_n(&self, n: usize) -> Vec<LeaderboardEntry>;
    // fn filter_players(self, filter: LeaderboardFilter) -> Vec<LeaderboardEntry>;
    // fn get_player_rank(self, player_id: ContractAddress) -> Option<u32>;
    // fn get_summary(&self) -> LeaderboardSummary;
    // fn batch_update_entries(mut self, updates: Vec<LeaderboardEntry>);
    // fn save_snapshot(self);
    // fn get_snapshot(self, timestamp: u64) -> Option<Leaderboard>;
    // fn merge_leaderboards(mut self, other: Leaderboard);
    // fn last_updated_string(self) -> felt252;
}


#[generate_trait]
impl LeaderboardImpl of LeaderboardTrait {
    fn add_entry(ref self: Leaderboard, mut entry: LeaderboardEntry) -> Result<(), felt252> {
        if self.is_full() {
            return Result::Err('Leaderboard is full');
        }
        // Assign an initial value
        entry.rank = self.entries.len() + 1;
        // Add new entry
        self.entries.append(entry);
        // Sort array DONT WORK
        // let sorted = merge(entries_span);
        // Update timestamp
        self.last_updated = starknet::get_block_timestamp();
        Result::Ok(())
    }

    fn is_full(self: @Leaderboard) -> bool {
        self.entries.len() >= MAX_ENTRIES
    }


}


