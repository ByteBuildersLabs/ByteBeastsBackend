use array::ArrayTrait;
use option::OptionTrait;

#[derive(Drop, Serde, Clone)]
#[dojo::model]
pub struct Season {
    #[key]
    pub season_id: u64,
    pub name: felt252,
    pub start_date: u64,
    pub end_date: u64,
    pub is_active: bool,
    pub active_players: Array<u64>,
}

#[derive(Drop, Serde, Clone)]
#[dojo::model]
pub struct SeasonManager {
    #[key]
    pub manager_id: u64,
    pub seasons: Array<Season>,
}

#[generate_trait]
impl SeasonManagerImpl of SeasonManagerTrait {
    fn create_season(
        ref self: SeasonManager,
        season_id: u64,
        name: felt252,
        start_date: u64,
        end_date: u64,
        is_active: bool,
        active_players: Array<u64>
    ) -> felt252 {
        let new_season = Season {
            season_id,
            name,
            start_date,
            end_date,
            is_active,
            active_players,
        };

        self.seasons.append(new_season);
        'Season created successfully'
    }

    fn update_season(
        ref self: SeasonManager,
        season_id: u64,
        new_name: Option<felt252>,
        new_start_date: Option<u64>,
        new_end_date: Option<u64>,
        new_is_active: Option<bool>,
    ) -> felt252 {

        let mut current_seasons = self.seasons;
        self.seasons = ArrayTrait::new();
        let mut found = false;
        let mut i = 0;
        loop {
            if i == current_seasons.len() {
                break;
            }

            let season = current_seasons.at(i).clone();

            if season.season_id == season_id {
                found = true;
                let updated_season = Season {
                    season_id: season.season_id,
                    name: match new_name {
                        Option::Some(new_name) => new_name,
                        Option::None => season.name,
                    },
                    start_date: match new_start_date {
                        Option::Some(new_start_date) => new_start_date,
                        Option::None => season.start_date,
                    },
                    end_date: match new_end_date {
                        Option::Some(end_date) => end_date,
                        Option::None => season.end_date,
                    },
                    is_active: match new_is_active {
                        Option::Some(is_active) => is_active,
                        Option::None => season.is_active,
                    },
                    active_players: season.active_players.clone(),
                };

                self.seasons.append(updated_season);
            } else {

                self.seasons.append(season.clone());
            }

            i += 1;
        };

        match found {
            true => 'Season updated successfully',
            false => 'Season not found',
        }
    }
    
    fn get_season(self: SeasonManager, season_id: u64) -> Season {
        let mut i = 0; 
        loop {
            if i == self.seasons.len() {
                break;
            }
    
            if *self.seasons.at(i).season_id == season_id {
                break;
            }
    
            i += 1;
        };
    
        self.seasons.at(i).clone()
    }

    fn get_active_seasons(self: SeasonManager) -> Array<Season> {
        let mut active_seasons = ArrayTrait::new();

        let mut i = 0;
        loop {
            if i == self.seasons.len() {
                break;
            }

            let season = self.seasons.at(i);
            if *season.is_active {
                active_seasons.append(season.clone());
            }

            i += 1;
        };

        active_seasons
    }

fn delete_season(ref self: SeasonManager, season_id: u64) -> felt252 {
    let mut updated_seasons = ArrayTrait::new();
    let mut found = false;

    let mut i = 0;
    loop {
        if i == self.seasons.len() {
            break;
        }

        let season = self.seasons.at(i);
        if *season.season_id != season_id {
            updated_seasons.append(season.clone());
        } else {
            found = true;
        }

        i += 1;
    };

    self.seasons = updated_seasons;

    match found {
        true => 'Season deleted successfully',
        false => 'Season not found',
    }
}

fn update_active_players(
    ref self: SeasonManager,
    season_id: u64,
    new_active_players: Array<u64>
) -> felt252 {

    let mut current_seasons = self.seasons;
    self.seasons = ArrayTrait::new();
    let mut found = false;
    let mut i = 0;
    loop {
        if i == current_seasons.len() {
            break;
        }
        let season = current_seasons.at(i).clone();

        if season.season_id == season_id {
            found = true;
            let updated_season = Season {
                season_id: season.season_id,
                name: season.name,
                start_date: season.start_date,
                end_date: season.end_date ,
                is_active: season.is_active,
                active_players: new_active_players.clone(),
            };
            self.seasons.append(updated_season);
        } else {

            self.seasons.append(season.clone());
        }

        i += 1;
    };

    match found {
        true => 'active players updated',
        false => 'Season not found',
    }
}

fn add_player_to_season(ref self: SeasonManager, season_id: u64, player_id: u64) -> felt252 {
    let mut i = 0;
    let mut updated = false;
    let mut result_message = 'Season not found';
    loop {
        if i == self.seasons.len() {
            break;
        }

        let mut season = self.seasons.at(i).clone();

        if season.season_id == season_id {
            let mut j = 0;
            let mut player_exists = false;

            loop {
                if j == season.active_players.len() {
                    break;
                }

                if *season.active_players.at(j) == player_id {
                    player_exists = true;
                    break;
                }

                j += 1;
            };

            if player_exists {
                result_message = 'Player already in season';
                break;
            }
            season.active_players.append(player_id);
            self.update_active_players(
                season_id: season.season_id,
                new_active_players: season.active_players,
            );
            updated = true;
            result_message = 'Player added successfully';
            break;
        }

        i += 1;
    };

    result_message
}


}

#[cfg(test)]
mod tests {
    use super::{Season, SeasonManager, SeasonManagerImpl};
    use array::ArrayTrait;

    #[test]
    fn test_create_season() {
        let mut manager = SeasonManager {
            manager_id: 1,
            seasons: ArrayTrait::new(),
        };

        let result = manager.create_season(1, 'Season One', 1672531200, 1675219599, true, ArrayTrait::new());
        assert(result == 'Season created successfully', 'Failed to create a season');
        assert(manager.seasons.len() == 1, 'list should contain 1 item');
    }

    #[test]
    fn test_update_season() {
        let mut manager = SeasonManager {
            manager_id: 1,
            seasons: ArrayTrait::new(),
        };

        manager.create_season(1, 'Initial Season', 1672531200, 1675219599, true, ArrayTrait::new());

        let result = manager.update_season(
            1,
            Option::Some('Updated Season'),
            Option::None,
            Option::Some(1677803999),
            Option::Some(false),
        );

        assert(result == 'Season updated successfully', 'Failed to update the season');
        let updated_season = manager.get_season(1);
        assert(updated_season.name == 'Updated Season', 'Name was not updated');
        assert(updated_season.end_date == 1677803999, 'End date was not updated');
        assert(!updated_season.is_active, 'is_active was not updated');
    }

    #[test]
    fn test_get_season() {
        let mut manager = SeasonManager {
            manager_id: 1,
            seasons: ArrayTrait::new(),
        };

        manager.create_season(1, 'Season A', 1672531200, 1675219599, true, ArrayTrait::new());
        let season = manager.get_season(1);
        assert(season.season_id == 1, 'Incorrect season ID retrieved');
        assert(season.name == 'Season A', 'Incorrect season name retrieved');
    }

    #[test]
    fn test_get_active_seasons() {
        let mut manager = SeasonManager {
            manager_id: 1,
            seasons: ArrayTrait::new(),
        };

        manager.create_season(1, 'Active Season', 1672531200, 1675219599, true, ArrayTrait::new());
        manager.create_season(2, 'Inactive Season', 1672531200, 1675219599, false, ArrayTrait::new());

        let active_seasons = manager.get_active_seasons();
        assert(active_seasons.len() == 1, 'one active season should exist');
        assert(*active_seasons.at(0).season_id == 1, 'wrong active season retrieved');
    }

    #[test]
    fn test_delete_season() {
        let mut manager = SeasonManager {
            manager_id: 1,
            seasons: ArrayTrait::new(),
        };

        manager.create_season(1, 'To Be Deleted', 1672531200, 1675219599, true, ArrayTrait::new());
        let result = manager.delete_season(1);
        assert(result == 'Season deleted successfully', 'Failed to delete the season');
        assert(manager.seasons.len() == 0, 'list should be empty');
    }

    #[test]
    fn test_update_active_players() {
        let mut manager = SeasonManager {
            manager_id: 1,
            seasons: ArrayTrait::new(),
        };
        manager.create_season(1, 'Test Season', 1672531200, 1675219599, true, ArrayTrait::new());

        let mut new_active_players = ArrayTrait::new();
        new_active_players.append(101);
        new_active_players.append(102);

        let result = manager.update_active_players(1, new_active_players.clone());
        assert(result == 'active players updated', 'unsuccessful player update');

        let updated_season = manager.get_season(1);
        assert(updated_season.active_players.len() == 2, 'players count is incorrect');
        assert(*updated_season.active_players.at(0) == 101, 'First player ID is incorrect');
        assert(*updated_season.active_players.at(1) == 102, 'Second player ID is incorrect');
    }

    #[test]
    fn test_add_player_to_season() {
    let mut manager = SeasonManager {
        manager_id: 1,
        seasons: ArrayTrait::new(),
    };
    manager.create_season(1, 'Test Season', 1672531200, 1675219599, true, ArrayTrait::new() );

    let result = manager.add_player_to_season(1, 101);
    assert(result == 'Player added successfully', 'Failed to add player to season');

    let season = manager.clone().get_season(1);
    assert(season.active_players.len() == 1, 'Player count is incorrect');
    assert(*season.active_players.at(0) == 101, 'Player ID is incorrect');

    let duplicate_result = manager.add_player_to_season(1, 101);
    assert(duplicate_result == 'Player already in season', 'should fail');

    let season_after_duplicate = manager.clone().get_season(1);
    assert(season_after_duplicate.active_players.len() == 1, 'count should not increase');

    let non_existent_result = manager.add_player_to_season(99, 102);
    assert(non_existent_result == 'Season not found', 'Non-existent season addition');
    }

    #[test]
    fn test_non_existent_season_operations() {
        let mut manager = SeasonManager {
            manager_id: 1,
            seasons: ArrayTrait::new(),
        };

        let delete_result = manager.delete_season(99);
        assert(delete_result == 'Season not found', 'Should return Season not found');

        let update_result = manager.update_season(
            99,
            Option::Some('Nonexistent'),
            Option::None,
            Option::None,
            Option::None,
        );
        assert(update_result == 'Season not found', 'Should return Season not found');
    }
}

