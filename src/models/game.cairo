use starknet::ContractAddress;
use super::game_player::GamePlayer;

#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
pub enum GameStatus {
    Pending: (),
    InProgress: (),
    Finished: (),
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Game {
    #[key]
    pub game_id: u128,
    pub player_1: ContractAddress,
    pub player_2: ContractAddress,
    pub player_3: ContractAddress,
    pub player_4: ContractAddress,
    pub status: GameStatus,
    pub is_private: bool,
}

pub trait GameTrait {
    fn new(game_id: u128, player_1: ContractAddress) -> Game;
    fn join_game(ref self: Game, player_2: GamePlayer);
}

pub impl GameImpl of GameTrait {
    // create the game
    fn new(game_id: u128, player_1: ContractAddress) -> Game {
        let game: Game = Game {
            game_id: game_id,
            player_1: player_1,
            player_2: core::num::traits::Zero::<ContractAddress>::zero(),
            player_3: core::num::traits::Zero::<ContractAddress>::zero(),
            player_4: core::num::traits::Zero::<ContractAddress>::zero(),
            status: GameStatus::InProgress,
            is_private: false,
        };
        game
    }

    // player two can join the game
    fn join_game(ref self: Game, player_2: GamePlayer) {
        self.player_2 = player_2.address;
    }
}
