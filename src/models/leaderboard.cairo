use starknet::ContractAddress;
use alexandria_data_structures::array_ext::ArrayTraitExt;
use alexandria_sorting::bubble_sort::bubble_sort_elements;
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

//trait for sorting by score
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

//trait for search by player_id
impl LeaderboardEntryPartialEq of PartialEq<LeaderboardEntry> {
    fn eq(lhs: @LeaderboardEntry, rhs: @LeaderboardEntry) -> bool {
        lhs.player_id == rhs.player_id
    }

    fn ne(lhs: @LeaderboardEntry, rhs: @LeaderboardEntry) -> bool {
        lhs.player_id != rhs.player_id
    }
}

// impl SpanLeaderboardEntryPartialOrd of PartialOrd<@LeaderboardEntry> {
//     fn le(lhs: @LeaderboardEntry, rhs: @LeaderboardEntry) -> bool {
//         // less than or equal
//         lhs.player_id <= rhs.player_id
//     }

//     fn ge(lhs: @LeaderboardEntry, rhs: @LeaderboardEntry) -> bool {
//         // greater than or equal
//         lhs.player_id >= rhs.player_id
//     }

//     fn lt(lhs: @LeaderboardEntry, rhs: @LeaderboardEntry) -> bool {
//         lhs.player_id < rhs.player_id
//     }

//     fn gt(lhs: @LeaderboardEntry, rhs: @LeaderboardEntry) -> bool {
//         lhs.player_id > rhs.player_id
//     }
// }

// impl SpanLeaderboardEntryPartialEq of PartialEq<@LeaderboardEntry> {
//     fn eq(lhs: @@LeaderboardEntry, rhs: @@LeaderboardEntry) -> bool {
//         lhs.player_id == rhs.player_id
//     }

//     fn ne(lhs: @@LeaderboardEntry, rhs: @@LeaderboardEntry) -> bool {
//         lhs.player_id != rhs.player_id
//     }
// }


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
    fn update_entry(ref self: Leaderboard, entry: LeaderboardEntry) -> Result<(), felt252>;
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
        // look for entry by player_id
        let res = self.entries.index_of(entry);
        if res.is_some() {
            return Result::Err('Entry already exists');
        }
        self.entries.append(entry);
        // Sort array by score
        let sorted = bubble_sort_elements(self.entries.clone(), true);
        self.entries = sorted;
        // Update timestamp
        self.last_updated = starknet::get_block_timestamp();
        Result::Ok(())
    }

    fn update_entry(ref self: Leaderboard, entry: LeaderboardEntry) -> Result<(), felt252> {
        // we have to devide array into two parts change the entry and merge them back
        // Find entry
        let res = self.entries.index_of(entry);
        if res.is_none() {
            return Result::Err('Entry not found');
        }
        let index = res.unwrap();
        let mut left = 0;
        if index != 0 {
            let mut left = self.entries.pop_front_n(index);
            left.append(entry);
            let _ = self.entries.pop_front();
            self.entries = left.append_all(ref self.entries);
        }
        else {
            let mut left = array![entry];
            let _ = self.entries.pop_front();
        }
        self.entries = left.append_all(ref self.entries);
        // Update entry
        self.last_updated = starknet::get_block_timestamp();
        Result::Ok(())
    }



}


