#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Player {
    #[key]
    pub player_id: u32,
    pub player_name: felt252,
    pub beast_1: u32,
    pub beast_2: u32,
    pub beast_3: u32,
    pub beast_4: u32,
    pub potions: u32,
}

#[cfg(test)]
mod tests {
    use bytebeasts::{models::{player::Player},};

    #[test]
    fn test_player_initialization() {
        let player = Player {
            player_id: 1,
            player_name: 'Hero',
            beast_1: 1,
            beast_2: 2,
            beast_3: 3,
            beast_4: 4,
            potions: 5,
        };

        assert_eq!(player.player_name, 'Hero', "Player name should be 'Hero'");
        assert_eq!(player.potions, 5, "Player should have 5 potions");
    }
}
