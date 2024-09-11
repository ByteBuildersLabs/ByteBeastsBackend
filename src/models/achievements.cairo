use super::achievement_type::AchievementType;
use super::achievement_rarity::AchievementRarity;

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Achievement {
    #[key]
    pub achievement_id: u64,               // Unique ID for the achievement
    pub achievement_type: AchievementType, // Type of achievement (e.g., FirstWin, TenWins)
    pub rarity: AchievementRarity,         // Rarity of the achievement
    pub name: felt252,                     // Name of the achievement
    pub description: felt252,              // Detailed description of the achievement
    pub is_hidden: bool,                   // Whether the achievement is hidden by default
    pub is_unlocked: bool,                 // Whether the achievement has been unlocked by the player
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct AchievementProgress {
    #[key]
    pub player_id: u64,                    // Player ID
    pub achievement_id: u64,               // Achievement ID
    pub progress: u32,                     // Progress to unlock achievement
    pub is_unlocked: bool,                 // If achievement is unlock or not
}

trait AchievementBehavior {
    fn check_unlock_condition(self: @Achievement, progress: u32) -> bool;
    // fn unlock(ref self: Achievement, ref progress: AchievementProgress) -> Result<(), felt252>;
}

#[generate_trait]
impl AchievementImpl of AchievementTrait {
    fn check_unlock_condition(self: @Achievement, progress: u32) -> bool {
        match self.achievement_type {
            AchievementType::FirstWin => progress >= 1,
            AchievementType::TenWins => progress >= 10,
            AchievementType::HundredWins => progress >= 100,
            AchievementType::FirstBeast => progress >= 1,
            AchievementType::TenBeasts => progress >= 10,
            AchievementType::RareBeast => progress >= 1,
            AchievementType::FirstNPCInteraction => progress >= 1,
            AchievementType::RandomBattleChampion => progress >= 3,
            AchievementType::BeastMaster => progress >= 5,
            AchievementType::LegendaryPlayer => progress >= 50,
            AchievementType::TopScorer => progress >= 100,
        }
    }

    // fn unlock(ref self: Achievement, ref mut progress: AchievementProgress) -> Result<(), felt252> {
    //     if !progress.is_unlocked && self.check_unlock_condition(progress.progress) {
    //         progress.is_unlocked = true;
    //         self.is_unlocked = true;
    //         Result::Ok(())
    //     } else {
    //         Result::Err(felt252_str!("Condition not met"))
    //     }
    // }
}



