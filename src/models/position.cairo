use super::coordinates::Coordinates;
use super::player::Player;

#[derive(Drop, Copy, Serde)]
#[dojo::model]
struct Position {
    #[key]
    player: Player,
    coordinates: Coordinates,
}