use starknet::ContractAddress;
use core::{
    result::Result,
    option::OptionTrait,
    array::ArrayTrait
};
use alexandria_data_structures::array_ext::ArrayTraitExt;
use alexandria_sorting::bubble_sort::bubble_sort_elements;

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
    // generic fn pop_front_n of ArrayTraitExt does not work properly, so its my implementation 
    // only for internal use
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

    fn get_index_by_player_id(ref self: Leaderboard, player_id: u32) -> Result<u32, felt252> {
        let entry = LeaderboardEntry {
            player_id: player_id,
            player_name: '',
            score: 0,
            rank: 0,
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
                Result::Ok(())
            },
            Option::None => Result::Err('Entry not found'),
        }
    }

    fn update_entry(ref self: Leaderboard, entry: LeaderboardEntry) -> Result<(), felt252> {
        // updates user entry in leaderboard
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
}

#[cfg(test)]
mod tests {
    use core::{
        result::{Result, ResultTrait},
        array::ArrayTrait,
    };
    use super::{LeaderboardTrait, MAX_ENTRIES};
    use bytebeasts::models::leaderboard::{Leaderboard, LeaderboardEntry};
    use alexandria_data_structures::array_ext::ArrayTraitExt;
    use alexandria_sorting::bubble_sort::bubble_sort_elements;

    fn create_mock_entry(player_id: u32, name: felt252, score: u32, wins: u32, losses: u32, highest_score: u32, is_active: bool) -> LeaderboardEntry {
        LeaderboardEntry {
            player_id: player_id,
            player_name: name,
            score: score,
            rank: 0,
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
    
    }

    #[test]
    fn test_add_multiple_entry() {
        let mut leaderboard = create_empty_leaderboard();
        let entry1 = create_mock_entry(12, 'Alice', 1100, 10, 5, 100, true);
        let entry2 = create_mock_entry(2, 'Bob', 200121, 20, 10, 200, true);
        let entry3 = create_mock_entry(34, 'Charlie', 1300, 30, 15, 300, true);
        let entry4 = create_mock_entry(9, 'David', 22400, 40, 20, 400, true);
        let entry5 = create_mock_entry(5, 'Eve', 500, 50, 25, 500, true);

        let entries = array![entry1, entry2, entry3, entry4, entry5];
        let not_added = leaderboard.add_batch(entries);
        assert_eq!(leaderboard.entries.len(), 5, "Wrong number of entries");
        assert_eq!(not_added.len(), 0, "Wrong number of not added entries");
        assert_eq!(leaderboard.entries.at(0).player_name, @'Bob', "Wrong first player name");
        assert_eq!(leaderboard.entries.at(4).player_name, @'Eve', "Wrong last player name");
    }
}
