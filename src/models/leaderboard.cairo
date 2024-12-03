use starknet::ContractAddress;
use core::{
    result::Result,
    option::OptionTrait,
    array::ArrayTrait
};
use alexandria_data_structures::array_ext::ArrayTraitExt;
use alexandria_sorting::bubble_sort::bubble_sort_elements;


#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct LeaderboardEntry {
    #[key]
    pub player_id: u32,                     // player ID
    pub player_name: felt252,               // Display name
    pub score: u32,                         // Overall score
    pub wins: u32,                          // Total wins
    pub losses: u32,                        // Total losses
    pub highest_score: u32,                 // Highest score in a single game
    pub is_active: bool,                    // Whether the player is currently active
}

//trait for sorting by score
impl LeaderboardEntryPartialOrd of PartialOrd<LeaderboardEntry> {
    fn le(lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> bool {
        lhs.score <= rhs.score
    }

    fn ge(lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> bool {
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


#[generate_trait]
impl LeaderboardImpl of LeaderboardTrait {
    // PRIVATE METHODS

    fn pop_front_n(ref self: Leaderboard, mut n: usize) -> Array<LeaderboardEntry> {
    // pops n elements from the front of the array, and returns them 
    // Alexandria implementation of pop_front_n does not return the popped elements
    // in the current version of the library
        let mut res: Array<LeaderboardEntry> = array![];

        while (n != 0) {
            match self.entries.pop_front() {
                Option::Some(e) => {
                    res.append(e);
                    n -= 1;
                },
                Option::None => { break; },
            };
        };

        res
    }

    fn unsafe_add_entry(ref self: Leaderboard, entry: LeaderboardEntry) -> Result<(), felt252> {
        // adds user entry to leaderboard without sorting
        let res = self.entries.index_of(entry);
        if res.is_some() {
            return Result::Err('Entry already exists');
        }
        self.entries.append(entry);
        self.last_updated = starknet::get_block_timestamp();
        Result::Ok(())
    }


    // PUBLIC METHODS

    fn get_leaderboard_length(ref self: Leaderboard) -> u32 {
        // returns number of entries in the leaderboard
        self.entries.len()
    }


    fn calculate_score (ref self: Leaderboard, wins: u32, highest_score: u32, losses: u32) -> u32 {
        // calculates score based on wins, losses and highest score
        wins * 100 + highest_score - losses * 70
    }


    fn upgrade_entry_stats(ref self: Leaderboard, player_id: u32, new_wins: u32, new_losses: u32, new_highest_score: u32) -> Result<(), felt252> {
        // recalculates score and updates entry in the leaderboard
        // addning new wins, losses and changing highest score to an old entry
        match self.get_index_by_player_id(player_id) {
            Result::Ok(index) => {
                let entry = self.entries.at(index);
                let total_wins: u32 = *entry.wins + new_wins;
                let total_losses: u32 = *entry.losses + new_losses;
                let highest_score: u32 = if new_highest_score > *entry.highest_score { new_highest_score } else { *entry.highest_score };
                match self.update_entry( LeaderboardEntry {
                    score: self.calculate_score(total_wins, highest_score, total_losses),
                    wins: total_wins,
                    losses: total_losses,
                    highest_score: highest_score,
                    ..*entry
                }) {
                    Result::Ok(_) => Result::Ok(()),
                    Result::Err(e) => Result::Err(e),
                }
            },
            Result::Err(e) => Result::Err(e),
        }
    }

    fn get_index_by_player_id(ref self: Leaderboard, player_id: u32) -> Result<u32, felt252> {
        // returns index of entry with given player_id. Index stands for rank in the leaderboard
        // player with highest score has index 0  
        let entry = LeaderboardEntry {
            player_id: player_id,
            player_name: '',
            score: 0,
            wins: 0,
            losses: 0,
            highest_score: 0,
            is_active: false,
        };
        match self.entries.index_of(entry) {
            Option::Some(index) => Result::Ok(index),
            Option::None => Result::Err('Entry not found'),
        }
    }


    fn add_entry(ref self: Leaderboard, entry: LeaderboardEntry) -> Result<(), felt252> {
        // adds user entry to leaderboard and sorts internal Array
        let res = self.entries.index_of(entry);
        if res.is_some() {
            return Result::Err('Entry already exists');
        }
        self.entries.append(entry);
        self.entries = bubble_sort_elements(self.entries, false);
        self.last_updated = starknet::get_block_timestamp();
        Result::Ok(())
    }

    fn add_batch(ref self: Leaderboard, mut entries: Array<LeaderboardEntry>) -> Array<LeaderboardEntry> {
        // adds multiple entries, sorts it and returns array of entries that were not added
        let mut not_added: Array<LeaderboardEntry> = array![];
        let mut res = entries.pop_front();
        while (res.is_some()) {
            let entry = res.unwrap();
            match self.unsafe_add_entry(entry) {
                Result::Err(_) => { not_added.append(entry); },
                Result::Ok(_) => {},
            };
            res = entries.pop_front();
        };
        self.entries = bubble_sort_elements(self.entries, false);
        not_added
    }

    fn remove_entry(ref self: Leaderboard, entry: LeaderboardEntry) -> Result<(), felt252> {
        // removes user entry from leaderboard
        match self.entries.index_of(entry) {
            Option::Some(index) => {
                let mut left = self.pop_front_n(index);
                let _ = self.entries.pop_front();
                left.append_all(ref self.entries);
                self.entries = left;
                self.last_updated = starknet::get_block_timestamp();
                Result::Ok(())
            },
            Option::None => Result::Err('Entry not found'),
        }
    }

    fn update_entry(ref self: Leaderboard, entry: LeaderboardEntry) -> Result<(), felt252> {
        // updates user entry in leaderboard, sorts array
        match self.remove_entry(entry) {
            Result::Ok(_) => {
                match self.add_entry(entry) {
                    Result::Ok(_) => Result::Ok(()),
                    Result::Err(e) => Result::Err(e)
                }
            },
            Result::Err(e) => Result::Err(e),
        }
    }


    fn get_entries(ref self: Leaderboard) -> Array<LeaderboardEntry> {
        // returns all entries in the leaderboard
        self.entries.clone()
    }

    fn get_slice(ref self: Leaderboard, start: u32, end: u32) -> Result<Array<LeaderboardEntry>, felt252> {
        // returns entries from start to end (exclusive)
        // can be used to get top of the leaderboard
        let mut res: Array<LeaderboardEntry> = array![];
        match self.entries.len() {
            0 => Result::Err('Leaderboard is empty'),
            _ => {
                if (start >= end) {
                    return Result::Err('Invalid range');
                }
                if (end > self.entries.len()) {
                    return Result::Err('End index out of bounds');
                }
                let mut i = start;
                while (i < end) {
                    res.append(self.entries.at(i).clone());
                    i += 1;
                };
                Result::Ok(res)
            },
        }
    }

}
