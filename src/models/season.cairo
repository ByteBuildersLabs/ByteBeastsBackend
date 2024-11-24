use alexandria::array::ArrayTrait;
use dojo::model;

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Season {
    #[key]
    pub season_id: u32,
    pub name: String,
    pub start_date: u64,
    pub end_date: u64,
    pub is_active: bool,
    pub active_players: Array<u32>,
}

#[derive(Drop, Serde)]
#[dojo::model]
pub struct SeasonManager {
    seasons: Array<Season>,
}

impl SeasonManager {
    pub fn create_season(
        &mut self,
        season_id: u32,
        name: String,
        start_date: u64,
        end_date: u64,
        is_active: bool,
    ) {
        let season = Season {
            season_id,
            name,
            start_date,
            end_date,
            is_active,
            active_players: ArrayTrait::new(),
        };
        self.seasons.append(season);
    }

    pub fn update_season(
        &mut self,
        season_id: u32,
        name: Option<String>,
        start_date: Option<u64>,
        end_date: Option<u64>,
        is_active: Option<bool>,
    ) {
        for season in self.seasons.iter_mut() {
            if season.season_id == season_id {
                if let Some(updated_name) = name {
                    season.name = updated_name;
                }
                if let Some(updated_start_date) = start_date {
                    season.start_date = updated_start_date;
                }
                if let Some(updated_end_date) = end_date {
                    season.end_date = updated_end_date;
                }
                if let Some(updated_status) = is_active {
                    season.is_active = updated_status;
                }
            }
        }
    }

    pub fn add_player(&mut self, season_id: u32, player_id: u32) {
        for season in self.seasons.iter_mut() {
            if season.season_id == season_id {
                season.active_players.append(player_id);
            }
        }
    }

    pub fn remove_player(&mut self, season_id: u32, player_id: u32) {
        for season in self.seasons.iter_mut() {
            if season.season_id == season_id {
                let player_index = season.active_players.index_of(&player_id);
                if let Some(index) = player_index {
                    season.active_players.remove(index);
                }
            }
        }
    }

    pub fn is_season_active(&self, season_id: u32) -> bool {
        for season in &self.seasons {
            if season.season_id == season_id {
                return season.is_active;
            }
        }
        false
    }

    pub fn get_active_players(&self, season_id: u32) -> Option<&Array<u32>> {
        for season in &self.seasons {
            if season.season_id == season_id {
                return Some(&season.active_players);
            }
        }
        None
    }

    pub fn get_season(&self, season_id: u32) -> Option<&Season> {
        for season in &self.seasons {
            if season.season_id == season_id {
                return Some(season);
            }
        }
        None
    }

    pub fn get_active_seasons(&self) -> Array<&Season> {
        let mut active_seasons = ArrayTrait::new();
        for season in &self.seasons {
            if season.is_active {
                active_seasons.append(season);
            }
        }
        active_seasons
    }

    pub fn deactivate_all_seasons(&mut self) {
        for season in self.seasons.iter_mut() {
            season.is_active = false;
        }
    }

    pub fn delete_season(&mut self, season_id: u32) {
        let season_index = self.seasons.iter().position(|s| s.season_id == season_id);
        if let Some(index) = season_index {
            self.seasons.remove(index);
        }
    }

    pub fn get_all_seasons(&self) -> &Array<Season> {
        &self.seasons
    }
}

#[cfg(test)]
mod tests {
    use super::{Season, SeasonManager};
    use alexandria::array::ArrayTrait;

    #[test]
    fn test_create_and_update_season() {
        let mut season_manager = SeasonManager {
            seasons: ArrayTrait::new(),
        };

        season_manager.create_season(
            1,
            "season1".to_string(),
            1640995200,
            1643673600,
            true,
        );

        let season = season_manager.get_all_seasons()[0];

        assert!(season.is_active, "Season should be active");

        season_manager.update_season(
            1,
            Some("updated_season1".to_string()),
            None,
            Some(1646092800),
            Some(false),
        );

        let updated_season = season_manager.get_all_seasons()[0];

        assert_eq!(updated_season.name, "updated_season1", "Season name mismatch");
        assert_eq!(updated_season.end_date, 1646092800, "End date mismatch");
        assert!(!updated_season.is_active, "Season should be inactive");
    }

    #[test]
    fn test_add_and_remove_players() {
        let mut season_manager = SeasonManager {
            seasons: ArrayTrait::new(),
        };

        season_manager.create_season(
            2,
            "season2".to_string(),
            1640995200,
            1643673600,
            true,
        );

        season_manager.add_player(2, 101);
        season_manager.add_player(2, 102);

        season_manager.remove_player(2, 101);

        let active_players = season_manager.get_active_players(2).unwrap();
        assert_eq!(active_players.len(), 1, "Player removal failed");
        assert_eq!(active_players[0], 102, "Incorrect remaining player");
    }

    #[test]
    fn test_get_season() {
        let mut season_manager = SeasonManager {
            seasons: ArrayTrait::new(),
        };

        season_manager.create_season(
            3,
            "season3".to_string(),
            1643673600,
            1646092800,
            true,
        );

        let season = season_manager.get_season(3).expect("Season not found");
        assert_eq!(season.name, "season3", "Incorrect season retrieved");
        assert!(season.is_active, "Season should be active");
    }

    #[test]
    fn test_get_active_seasons() {
        let mut season_manager = SeasonManager {
            seasons: ArrayTrait::new(),
        };

        season_manager.create_season(
            4,
            "season4".to_string(),
            1640995200,
            1643673600,
            true,
        );

        season_manager.create_season(
            5,
            "season5".to_string(),
            1643673600,
            1646092800,
            false,
        );

        let active_seasons = season_manager.get_active_seasons();
        assert_eq!(active_seasons.len(), 1, "Active season count mismatch");
        assert_eq!(active_seasons[0].name, "season4", "Incorrect active season");
    }

    #[test]
    fn test_deactivate_all_seasons() {
        let mut season_manager = SeasonManager {
            seasons: ArrayTrait::new(),
        };

        season_manager.create_season(
            6,
            "season6".to_string(),
            1640995200,
            1643673600,
            true,
        );

        season_manager.create_season(
            7,
            "season7".to_string(),
            1643673600,
            1646092800,
            true,
        );

        season_manager.deactivate_all_seasons();

        for season in season_manager.get_all_seasons() {
            assert!(!season.is_active, "Season should be inactive");
        }
    }

    #[test]
    fn test_delete_season() {
        let mut season_manager = SeasonManager {
            seasons: ArrayTrait::new(),
        };

        season_manager.create_season(
            8,
            "season8".to_string(),
            1640995200,
            1643673600,
            true,
        );

        season_manager.delete_season(8);

        assert_eq!(season_manager.get_all_seasons().len(), 0, "Season deletion failed");
    }
}
