
#[cfg(test)]
mod tests {
    use bytebeasts::models::season::{
        SeasonManager, SeasonManagerImpl
    };

    use bytebeasts::{
        systems::{season::{season_system, ISeasonAction}}
    };

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
