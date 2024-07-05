use dojo_starter::models::moves::Direction;
use dojo_starter::models::position::Position;
use dojo_starter::models::beast::Beast;

// define the interface
#[dojo::interface]
trait IActions {
    fn spawn(ref world: IWorldDispatcher);
    fn move(ref world: IWorldDispatcher, direction: Direction);
    fn attack(ref world: IWorldDispatcher, beast_id: u32, damage: u32);
    fn createBeast(ref world: IWorldDispatcher, beast_id: u32, beast_type: felt252, hp: u32, currentHp: u32, mp: u64, currentMp: u64, strength: u64, defense: u64, equipped_weapon: felt252, wpn_power: u8, equipped_armor: felt252, armor_power: u64, experience_to_nex_level: u64);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions, next_position};
    use starknet::{ContractAddress, get_caller_address};
    use dojo_starter::models::{
        position::{Position, Vec2}, moves::{Moves, Direction, DirectionsAvailable}, beast::{Beast}
    };

    #[derive(Copy, Drop, Serde)]
    #[dojo::model]
    #[dojo::event]
    struct Moved {
        #[key]
        player: ContractAddress,
        direction: Direction,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn spawn(ref world: IWorldDispatcher) {
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();
            // Retrieve the player's current position from the world.
            let position = get!(world, player, (Position));

            // Update the world state with the new data.
            // 1. Set the player's remaining moves to 100.
            // 2. Move the player's position 10 units in both the x and y direction.
            // 3. Set available directions to all four directions. (This is an example of how you can use an array in Dojo).

            let directions_available = DirectionsAvailable {
                player,
                directions: array![
                    Direction::Up, Direction::Right, Direction::Down, Direction::Left
                ],
            };

            // Set world
            set!(
                world,
                (
                    Moves {
                        player, remaining: 100, last_direction: Direction::None(()), can_move: true
                    },
                    Position {
                        player, vec: Vec2 { x: position.vec.x + 10, y: position.vec.y + 10 }
                    },
                    directions_available
                )
            );
        }

        // Implementation of the move function for the ContractState struct.
        fn move(ref world: IWorldDispatcher, direction: Direction) {
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // Retrieve the player's current position and moves data from the world.
            let (mut position, mut moves) = get!(world, player, (Position, Moves));

            // Deduct one from the player's remaining moves.
            moves.remaining -= 1;

            // Update the last direction the player moved in.
            moves.last_direction = direction;

            // Calculate the player's next position based on the provided direction.
            let next = next_position(position, direction);

            // Update the world state with the new moves data and position.
            set!(world, (moves, next));
            // Emit an event to the world to notify about the player's move.
            emit!(world, (Moved { player, direction }));
        }

        fn attack(ref world: IWorldDispatcher, beast_id: u32, damage: u32) {
            let mut beast = get!(world, (beast_id), (Beast));
            beast.hp = beast.hp - damage;
            set!(world, (beast));
        }

        fn createBeast(
            ref world: IWorldDispatcher,
            beast_id: u32,
            beast_type: felt252,
            hp: u32,
            currentHp: u32,
            mp: u64,
            currentMp: u64,
            strength: u64,
            defense: u64,
            equipped_weapon: felt252,
            wpn_power: u8,
            equipped_armor: felt252,
            armor_power: u64,
            experience_to_nex_level: u64,
        ) {
            set!(
                world,
                (
                    Beast {
                        beast_id,
                        player_id: get_caller_address(),
                        beast_type,
                        hp,
                        currentHp,
                        mp,
                        currentMp,
                        strength,
                        defense,
                        equipped_weapon,
                        wpn_power,
                        equipped_armor,
                        armor_power,
                        experience_to_nex_level,
                    }
                )
            );
        }
    }
}

// Define function like this:
fn next_position(mut position: Position, direction: Direction) -> Position {
    match direction {
        Direction::None => { return position; },
        Direction::Left => { position.vec.x -= 1; },
        Direction::Right => { position.vec.x += 1; },
        Direction::Up => { position.vec.y -= 1; },
        Direction::Down => { position.vec.y += 1; },
    };
    position
}
