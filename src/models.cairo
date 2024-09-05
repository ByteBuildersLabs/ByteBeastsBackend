use starknet::{ContractAddress, SyscallResultTrait};

// New Models

// Game Player
#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct GamePlayer {
    #[key]
    pub address: ContractAddress,
    #[key]
    pub game_id: u128,
    pub beast_1: u8,
    pub beast_2: u8,
    pub beast_3: u8,
    pub beast_4: u8,
    pub bag_id: u8,
    pub active_mount: u8,
    pub mounts: Array<u8>,
    pub position: Array<u8>
}

pub trait GamePlayerTrait {
    fn new(game_id: u128, address: ContractAddress) -> GamePlayer;
}

impl GamePlayerImpl of GamePlayerTrait {
    // logic to create an instance of a game player
    fn new(game_id: u128, address: ContractAddress) -> GamePlayer {
        let game_player = GamePlayer {
            address: address,
            game_id: game_id,
            beast_1: 0_u8,
            beast_2: 0_u8,
            beast_3: 0_u8,
            beast_4: 0_u8,
            bag_id: 0_u8,
            active_mount: 0_u8,
            mounts: ArrayTrait::new(),
            position: ArrayTrait::new(),
        };
        game_player
    }
}

// Realm (Game)
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct GameId {
    #[key]
    pub id: u32,
    pub game_id: u128
}

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
