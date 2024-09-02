use super::coordinates::Coordinates;
use super::player::Player;

#[derive(Drop, Copy, Serde)]
#[dojo::model]
struct Position {
    #[key]
    player: Player,
    coordinates: Coordinates,
}

#[cfg(test)]
mod tests {
    use bytebeasts::models::player::Player;
    use bytebeasts::models::coordinates::Coordinates;
    use bytebeasts::models::position::Position;

    #[test]
    fn test_position_initialization() {
        let player = Player {
            player_id: 1,
            player_name: 'Hero',
            beast_1: 1,
            beast_2: 2,
            beast_3: 3,
            beast_4: 4,
            potions: 5,
        };

        let coordinates = Coordinates{
            x: 10,
            y: 10,
        };

        let position = Position {
            player: player,
            coordinates: coordinates
        };

        assert_eq!(position.player.player_id, 1, "Player ID should be 1");
        assert_eq!(position.coordinates.x, 10, "Player X coordinate should be 10");
        assert_eq!(position.coordinates.y, 10, "Player Y coordinate should be 10");
    }

}
