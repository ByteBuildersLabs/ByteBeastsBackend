use starknet::ContractAddress;
use dojo::model::Model;

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
    pub beast_3: u8,
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
