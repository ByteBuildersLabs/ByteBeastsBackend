use starknet::ContractAddress;
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
    pub player_address: ContractAddress,   // On-chain player address
    pub player_name: felt252,              // Display name
    pub score: u32,                        // Overall score
    pub rank: u32,                         // Rank in the leaderboard
    pub wins: u32,                         // Total wins
    pub losses: u32,                       // Total losses
    pub highest_score: u32,                // Highest score in a single game
    pub is_active: bool,                   // Whether the player is currently active
}


#[derive(Drop, Serde)]
#[dojo::model]
pub struct Leaderboard {
    #[key]
    pub leaderboard_id: u64,               // Unique ID for leaderboard (could be incremental)
    pub name: felt252,                     // Leaderboard name (e.g., "Global", "Monthly")
    pub description: felt252,              // Description of what this leaderboard tracks
    pub entries: Array<LeaderboardEntry>,  // List of leaderboard entries
    pub last_updated: u64,                 // Timestamp of last update
}

trait LeaderboardBehavior {
    fn add_entry(ref self: Leaderboard, entry: LeaderboardEntry) -> Result<(), felt252>;
    fn is_full(self: @Leaderboard) -> bool;
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
        // Update timestamp
        self.last_updated = starknet::get_block_timestamp();
        Result::Ok(())
    }

    fn is_full(self: @Leaderboard) -> bool {
        self.entries.len() >= MAX_ENTRIES
    }

}


#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use core::{
        result::{Result, ResultTrait},
        array::ArrayTrait,
    };
    use super::{LeaderboardTrait, MAX_ENTRIES};
    use bytebeasts::models::leaderboard::{Leaderboard, LeaderboardEntry};

    fn create_mock_entry(address: ContractAddress, name: felt252, score: u32, wins: u32, losses: u32, highest_score: u32, is_active: bool) -> LeaderboardEntry {
        LeaderboardEntry {
            player_address: address,
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
        let entry = create_mock_entry(starknet::get_contract_address(), 'Alice', 100, 20, 5, 1000, true);
        
        leaderboard.add_entry(entry).expect('Failed to add entry');
        
        assert_eq!(leaderboard.entries.len(), 1, "Leaderboard should have 1 entry");
        assert_eq!(leaderboard.entries.at(0).player_name, @'Alice', "Wrong player name");
        assert_eq!(leaderboard.entries.at(0).rank, @1, "First entry should have rank 1");
    }

    #[test]
    fn test_add_multiple_entries() {
        let mut leaderboard = create_empty_leaderboard();
        let entry1 = create_mock_entry(starknet::get_contract_address(), 'Alice', 100, 20, 5, 1000, true);
        let entry2 = create_mock_entry(starknet::get_contract_address(), 'Bob', 200, 30, 10, 1500, true);
        
        leaderboard.add_entry(entry1).expect('Failed to add entry1');
        leaderboard.add_entry(entry2).expect('Failed to add entry2');
        
        assert_eq!(leaderboard.entries.len(), 2, "Leaderboard should have 2 entries");
        assert_eq!(leaderboard.entries.at(0).rank, @1, "First entry should have rank 1");
        assert_eq!(leaderboard.entries.at(1).rank, @2, "Second entry should have rank 2");
    }

    #[test]
    fn test_leaderboard_full() {
        let mut leaderboard = create_empty_leaderboard();
        let entry = create_mock_entry(starknet::get_contract_address(), 'Player', 100, 10, 5, 500, true);

        // Add MAX_ENTRIES to the leaderboard
        let mut i = 0;
        while i < MAX_ENTRIES {
            leaderboard.add_entry(entry).expect('Failed to add entry');
            i += 1;
        };

        assert_eq!(leaderboard.entries.len(), MAX_ENTRIES, "Leaderboard should be full");
        assert!(leaderboard.is_full(), "Leaderboard should report as full");

        let result = leaderboard.add_entry(entry);
        assert!(result.is_err(), "Should not be able to add entry to full leaderboard");
    }

    #[test]
    fn test_entry_properties() {
        let mut leaderboard = create_empty_leaderboard();
        let entry = create_mock_entry(starknet::get_contract_address(), 'Alice', 100, 20, 5, 1000, true);
        
        leaderboard.add_entry(entry).expect('Failed to add entry');
        
        let added_entry = leaderboard.entries.at(0);
        assert_eq!(added_entry.player_name, @'Alice', "Wrong player name");
        assert_eq!(added_entry.score, @100, "Wrong score");
        assert_eq!(added_entry.wins, @20, "Wrong number of wins");
        assert_eq!(added_entry.losses, @5, "Wrong number of losses");
        assert_eq!(added_entry.highest_score, @1000, "Wrong highest score");
        assert_eq!(added_entry.is_active, @true,"Player should be active");
    }
}
