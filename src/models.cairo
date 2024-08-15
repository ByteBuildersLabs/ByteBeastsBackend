use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Beast {
    #[key]
    pub beast_id: u32,
    pub beast_name: felt252,
    pub beast_type: felt252,
    pub beast_description: felt252,
    pub player_id: felt252,
    pub hp: u32,
    pub current_hp: u32,
    pub attack: u64,
    pub defense: u64,
    pub mt1: u32,
    pub mt2: u32,
    pub mt3: u32,
    pub mt4: u32,
    pub level: u32,
    pub experience_to_nex_level: u64,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Mt {
    #[key]
    pub mt_id: u32,
    pub mt_name: felt252,
    pub mt_type: u32,
    pub mt_power: u32,
    pub mt_accuracy: u32,
}

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

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Potion {
    #[key]
    pub potion_id: u32,
    pub potion_name: felt252,
    pub potion_effect: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Moves {
    #[key]
    pub player: ContractAddress,
    pub remaining: u8,
    pub last_direction: Direction,
    pub can_move: bool,
}

#[derive(Drop, Serde)]
#[dojo::model]
pub struct DirectionsAvailable {
    #[key]
    pub player: ContractAddress,
    pub directions: Array<Direction>,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Position {
    #[key]
    pub player: ContractAddress,
    pub vec: Vec2,
}


#[derive(Serde, Copy, Drop, Introspect)]
pub enum Direction {
    None,
    Left,
    Right,
    Up,
    Down,
}


#[derive(Copy, Drop, Serde, Introspect)]
pub struct Vec2 {
    pub x: u32,
    pub y: u32
}


impl DirectionIntoFelt252 of Into<Direction, felt252> {
    fn into(self: Direction) -> felt252 {
        match self {
            Direction::None => 0,
            Direction::Left => 1,
            Direction::Right => 2,
            Direction::Up => 3,
            Direction::Down => 4,
        }
    }
}


#[generate_trait]
impl Vec2Impl of Vec2Trait {
    fn is_zero(self: Vec2) -> bool {
        if self.x - self.y == 0 {
            return true;
        }
        false
    }

    fn is_equal(self: Vec2, b: Vec2) -> bool {
        self.x == b.x && self.y == b.y
    }
}

#[cfg(test)]
mod tests {
    use super::{Position, Vec2, Vec2Trait};

    #[test]
    fn test_vec_is_zero() {
        assert(Vec2Trait::is_zero(Vec2 { x: 0, y: 0 }), 'not zero');
    }

    #[test]
    fn test_vec_is_equal() {
        let position = Vec2 { x: 420, y: 0 };
        assert(position.is_equal(Vec2 { x: 420, y: 0 }), 'not equal');
    }
}
