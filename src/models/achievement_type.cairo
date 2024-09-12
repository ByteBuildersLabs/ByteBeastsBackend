#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
pub enum AchievementType {
    FirstWin,
    TenWins,
    HundredWins,
    FirstBeast,
    TenBeasts,
    RareBeast,
    FirstNPCInteraction,
    RandomBattleChampion,
    BeastMaster,
    LegendaryPlayer,
    TopScorer,
}

impl AchievementTypeIntoFelt252 of Into<AchievementType, felt252> {
    fn into(self: AchievementType) -> felt252 {
        match self {
            AchievementType::FirstWin => 0,
            AchievementType::TenWins => 1,
            AchievementType::HundredWins => 2,
            AchievementType::FirstBeast => 3,
            AchievementType::TenBeasts => 4,
            AchievementType::RareBeast => 5,
            AchievementType::FirstNPCInteraction => 6,
            AchievementType::RandomBattleChampion => 7,
            AchievementType::BeastMaster => 8,
            AchievementType::LegendaryPlayer => 9,
            AchievementType::TopScorer => 10,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{AchievementType, AchievementTypeIntoFelt252};

    #[test]
    fn test_achievement_type_into_felt252() {

        let first_win = AchievementType::FirstWin;
        let ten_wins = AchievementType::TenWins;
        let hundred_wins = AchievementType::HundredWins;
        let first_beast = AchievementType::FirstBeast;
        let ten_beast = AchievementType::TenBeasts;
        let rare_beast = AchievementType::RareBeast;
        let first_npc_interaction = AchievementType::FirstNPCInteraction;
        let random_battle = AchievementType::RandomBattleChampion;
        let beast_master = AchievementType::BeastMaster;
        let legendary_player = AchievementType::LegendaryPlayer;
        let top_scorer = AchievementType::TopScorer;

        assert_eq!(first_win.into(), 0, "AchievementType::FirstWin deberia convertirse a 0");
        assert_eq!(ten_wins.into(), 1, "AchievementType::TenWins deberia convertirse a 1");
        assert_eq!(hundred_wins.into(), 2, "AchievementType::HundredWins deberia convertirse a 2");
        assert_eq!(first_beast.into(), 3, "AchievementType::FirstBeast deberia convertirse a 3");
        assert_eq!(ten_beast.into(), 4, "AchievementType::TenBeasts deberia convertirse a 4");
        assert_eq!(rare_beast.into(), 5, "AchievementType::RareBeast deberia convertirse a 5");
        assert_eq!(first_npc_interaction.into(), 6, "AchievementType::FirstNPCInteraction deberia convertirse a 6");
        assert_eq!(random_battle.into(), 7, "AchievementType::RandomBattleChampion deberia convertirse a 7");
        assert_eq!(beast_master.into(), 8, "AchievementType::BeastMaster deberia convertirse a 8");
        assert_eq!(legendary_player.into(), 9, "AchievementType::LegendaryPlayer deberia convertirse a 9");
        assert_eq!(top_scorer.into(), 10, "AchievementType::TopScorer deberia convertirse a 10");
    }
}
