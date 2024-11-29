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

    fn get_liderboard_length(ref self: Leaderboard) -> u32 {
        // returns number of entries in the leaderboard
        self.entries.len()
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

#[cfg(test)]
mod tests {
    use core::{
        result::{Result, ResultTrait},
        array::ArrayTrait,
    };
    use super::{LeaderboardTrait};
    use bytebeasts::models::leaderboard::{Leaderboard, LeaderboardEntry};
    use alexandria_data_structures::array_ext::ArrayTraitExt;
    use alexandria_sorting::bubble_sort::bubble_sort_elements;

    fn create_mock_entry(player_id: u32, name: felt252, score: u32, wins: u32, losses: u32, highest_score: u32, is_active: bool) -> LeaderboardEntry {
        LeaderboardEntry {
            player_id: player_id,
            player_name: name,
            score: score,
            wins: wins,
            losses: losses,
            highest_score: highest_score,
            is_active: is_active,
        }
    }

    fn create_empty_leaderboard() -> Leaderboard {
        Leaderboard {
            leaderboard_id: 1,
            name: 'Global Leaderboard',
            description: 'Top players worldwide',
            entries: ArrayTrait::new(),
            last_updated: 0,
        }
    }

    #[test]
    fn test_add_single_entry() {
        let mut leaderboard = create_empty_leaderboard();
        let entry = create_mock_entry(1, 'Alice', 100, 10, 5, 100, true);
        let res = leaderboard.add_entry(entry);
        assert_eq!(res.is_ok(), true);
        assert_eq!(leaderboard.entries.len(), 1);
        assert_eq!(leaderboard.entries.at(0).player_name, @'Alice', "Wrong player name");
    
        let duplicate_res = leaderboard.add_entry(entry);
        assert_eq!(duplicate_res.is_err(), true, "Duplicate entry should return error");
    }

    #[test]
    fn test_add_multiple_entry() {
        let mut leaderboard = create_empty_leaderboard();
        let entry1 = create_mock_entry(12, 'Alice', 1100, 10, 5, 100, true);
        let entry2 = create_mock_entry(2, 'Bob', 200121, 20, 10, 200, true);
        let entry3 = create_mock_entry(34, 'Charlie', 1300, 30, 15, 300, true);
        let entry4 = create_mock_entry(9, 'David', 22400, 40, 20, 400, true);
        let entry5 = create_mock_entry(5, 'Eve', 500, 50, 25, 500, true);

        let _ = leaderboard.add_entry(entry4);
        let _ = leaderboard.add_entry(entry5);
        let entries = array![entry1, entry2, entry3, entry4, entry5];
        let not_added = leaderboard.add_batch(entries);
        assert_eq!(leaderboard.entries.len(), 5, "Wrong number of entries");
        assert_eq!(not_added.len(), 2, "Wrong number of not added entries");
        assert_eq!(leaderboard.entries.at(0).player_name, @'Bob', "Wrong first player name");
        assert_eq!(leaderboard.entries.at(4).player_name, @'Eve', "Wrong last player name");

        let duplicate_entries = array![entry1, entry2];
        let not_added_duplicates = leaderboard.add_batch(duplicate_entries);
        assert_eq!(not_added_duplicates.len(), 2, "Duplicate entries should not be added");
    }

    #[test]
    fn test_pop_front_n() {
        let mut leaderboard = create_empty_leaderboard();
        let entry1 = create_mock_entry(12, 'Alice', 1100, 10, 5, 100, true);
        let entry2 = create_mock_entry(2, 'Bob', 200121, 20, 10, 200, true);
        let entry3 = create_mock_entry(34, 'Charlie', 1300, 30, 15, 300, true);
        let _ = leaderboard.add_batch(array![entry1, entry2, entry3]);
        let popped_entries = leaderboard.pop_front_n(2);
        assert_eq!(popped_entries.len(), 2, "Wrong number of popped entries");
        assert_eq!(popped_entries.at(0).player_name, @'Bob', "Wrong first popped player name");
        assert_eq!(popped_entries.at(1).player_name, @'Charlie', "Wrong second popped player name");
        assert_eq!(leaderboard.entries.len(), 1, "Wrong number of remaining entries");
        assert_eq!(leaderboard.entries.at(0).player_name, @'Alice', "Wrong remaining player name");

        let mut empty_leaderboard = create_empty_leaderboard();
        let popped_entries_empty = empty_leaderboard.pop_front_n(5);
        assert_eq!(popped_entries_empty.len(), 0, "Popping from empty leaderboard should return empty array");
    }

    #[test]
    fn test_remove_entry() {
        let mut leaderboard = create_empty_leaderboard();
        let entry1 = create_mock_entry(12, 'Alice', 1100, 10, 5, 100, true);
        let entry2 = create_mock_entry(2, 'Bob', 200121, 20, 10, 200, true);
        let entry3 = create_mock_entry(34, 'Charlie', 1300, 30, 15, 300, true);
        let entry4 = create_mock_entry(9, 'David', 22400, 40, 20, 400, true);
        let entry5 = create_mock_entry(5, 'Eve', 500, 50, 25, 500, true);

        let entries = array![entry1, entry2, entry3, entry4, entry5];
        let _ = leaderboard.add_batch(entries);
        let res = leaderboard.remove_entry(entry3);
        assert_eq!(res.is_ok(), true);
        assert_eq!(leaderboard.entries.len(), 4, "Wrong number of entries");
        assert_eq!(leaderboard.entries.at(2).player_name, @'Alice', "Wrong player name");

        let non_existent_entry = create_mock_entry(99, 'NonExistent', 0, 0, 0, 0, false);
        let res_non_existent = leaderboard.remove_entry(non_existent_entry);
        assert_eq!(res_non_existent.is_err(), true, "Removing non-existent entry should return error");
    }

    #[test]
    fn test_get_index_by_player_id() {
        let mut leaderboard = create_empty_leaderboard();
        let entry1 = create_mock_entry(12, 'Alice', 1100, 10, 5, 100, true);
        let entry2 = create_mock_entry(2, 'Bob', 200121, 20, 10, 200, true);
        let entry3 = create_mock_entry(34, 'Charlie', 1300, 30, 15, 300, true);
        let entry4 = create_mock_entry(9, 'David', 22400, 40, 20, 400, true);
        let entry5 = create_mock_entry(5, 'Eve', 500, 50, 25, 500, true);

        let _ = leaderboard.add_batch(array![entry1, entry2, entry3, entry4, entry5]);
        let rank = leaderboard.get_index_by_player_id(34).unwrap();
        assert_eq!(rank, 2, "Wrong rank for Charlie");
        let rank = leaderboard.get_index_by_player_id(2).unwrap();
        assert_eq!(rank, 0, "Wrong rank for Bob");
        let rank = leaderboard.get_index_by_player_id(5).unwrap();
        assert_eq!(rank, 4, "Wrong rank for Eve");

        let non_existent_rank = leaderboard.get_index_by_player_id(99);
        assert_eq!(non_existent_rank.is_err(), true, "Getting index of non-existent player should return error");
    }

    #[test]
    fn test_update_entry() {
        let mut leaderboard = create_empty_leaderboard();
        let entry1 = create_mock_entry(12, 'Alice', 1100, 10, 5, 100, true);
        let entry2 = create_mock_entry(2, 'Bob', 200121, 20, 10, 200, true);
        let entry3 = create_mock_entry(34, 'Charlie', 1300, 30, 15, 300, true);
        let entry4 = create_mock_entry(9, 'David', 22400, 40, 20, 400, true);
        let entry5 = create_mock_entry(5, 'Eve', 500, 50, 25, 500, true);

        let _ = leaderboard.add_batch(array![entry1, entry2, entry3, entry4, entry5]);
        let new_score: u32 = 100;
        let new_wins: u32 = 31;
        let updated_entry = create_mock_entry(34, 'Charlie', new_score, new_wins, 15, 300, true);
        let res = leaderboard.update_entry(updated_entry);
        let rank = leaderboard.get_index_by_player_id(34).unwrap();
        assert_eq!(res.is_ok(), true);
        assert_eq!(rank, 4, "Wrong rank");
        assert_eq!(leaderboard.entries.len(), 5, "Wrong number of entries");
        assert_eq!(leaderboard.entries.at(rank).score, @new_score, "Wrong score");
        assert_eq!(leaderboard.entries.at(rank).wins, @new_wins, "Wrong wins");

        let non_existent_entry = create_mock_entry(99, 'NonExistent', 0, 0, 0, 0, false);
        let res_non_existent = leaderboard.update_entry(non_existent_entry);
        assert_eq!(res_non_existent.is_err(), true, "Updating non-existent entry should return error");
    }

    #[test]
    fn test_get_entries() {
        let mut leaderboard = create_empty_leaderboard();
        let entry1 = create_mock_entry(12, 'Alice', 1100, 10, 5, 100, true);
        let entry2 = create_mock_entry(2, 'Bob', 200121, 20, 10, 200, true);
        let _ = leaderboard.add_batch(array![entry1, entry2]);
        let entries = leaderboard.get_entries();
        assert_eq!(entries.len(), 2, "Wrong number of entries");
        assert_eq!(entries.at(0).player_name, @'Bob', "Wrong first player name");
        assert_eq!(entries.at(1).player_name, @'Alice', "Wrong second player name");

        let mut empty_leaderboard = create_empty_leaderboard();
        let entries_empty = empty_leaderboard.get_entries();
        assert_eq!(entries_empty.len(), 0, "Empty leaderboard should return empty array");
    }

    #[test]
    fn test_get_slice() {
        let mut leaderboard = create_empty_leaderboard();
        let entry1 = create_mock_entry(12, 'Alice', 1100, 10, 5, 100, true);
        let entry2 = create_mock_entry(2, 'Bob', 200121, 20, 10, 200, true);
        let entry3 = create_mock_entry(34, 'Charlie', 1300, 30, 15, 300, true);
        let entry4 = create_mock_entry(9, 'David', 22400, 40, 20, 400, true);
        let entry5 = create_mock_entry(5, 'Eve', 500, 50, 25, 500, true);

        let _ = leaderboard.add_batch(array![entry1, entry2, entry3, entry4, entry5]);
        let slice = leaderboard.get_slice(1, 4).unwrap();
        assert_eq!(slice.len(), 3, "Wrong number of entries in slice");
        assert_eq!(slice.at(0).player_name, @'David', "Wrong first player name in slice");
        assert_eq!(slice.at(2).player_name, @'Alice', "Wrong last player name in slice");

        let invalid_slice = leaderboard.get_slice(4, 1);
        assert_eq!(invalid_slice.is_err(), true, "Invalid slice range should return error");

        let out_of_bounds_slice = leaderboard.get_slice(1, 10);
        assert_eq!(out_of_bounds_slice.is_err(), true, "Out of bounds slice should return error");

        let mut empty_leaderboard = create_empty_leaderboard();
        let empty_slice = empty_leaderboard.get_slice(0, 1);
        assert_eq!(empty_slice.is_err(), true, "Empty leaderboard should return error");
    }
}
