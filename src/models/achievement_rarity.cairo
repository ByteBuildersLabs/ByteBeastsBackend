#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
pub enum AchievementRarity {
    Common,
    Uncommon,
    Rare,
    Epic,
    Legendary,
}

impl AchievementRarityIntoFelt252 of Into<AchievementRarity, felt252> {
    fn into(self: AchievementRarity) -> felt252 {
        match self {
            AchievementRarity::Common => 0,
            AchievementRarity::Uncommon => 1,
            AchievementRarity::Rare => 2,
            AchievementRarity::Epic => 3,
            AchievementRarity::Legendary => 4,
        }
    }
}


#[cfg(test)]
mod tests {
    use super::{AchievementRarity, AchievementRarityIntoFelt252};

    #[test]
    fn test_achievement_rarity_into_felt252() {

        let common = AchievementRarity::Common;
        let uncommon = AchievementRarity::Uncommon;
        let rare = AchievementRarity::Rare;
        let epic = AchievementRarity::Epic;
        let legendary = AchievementRarity::Legendary;

        assert_eq!(common.into(), 0, "AchievementRarity::Common deberia convertirse a 0");
        assert_eq!(uncommon.into(), 1, "AchievementRarity::Uncommon deberia convertirse a 1");
        assert_eq!(rare.into(), 2, "AchievementRarity::Rare deberia convertirse a 2");
        assert_eq!(epic.into(), 3, "AchievementRarity::Epic deberia convertirse a 3");
        assert_eq!(legendary.into(), 4, "AchievementRarity::Legendary deberia convertirse a 4");
    }
}
