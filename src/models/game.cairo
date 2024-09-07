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

#[cfg(test)]
mod tests {
    use super::{Game, GameStatus, GameTrait};
    use starknet::ContractAddress;
    use super::game_player::GamePlayer;

    #[test]
    fn test_game_creation() {
        // Crear una dirección de contrato de prueba
        let player_1_address = ContractAddress::from(1234_u32);
        let game_id = 98765432101234567890123456789012_u128;

        // Crear el juego usando el método `new`
        let game = Game::new(game_id, player_1_address);

        // Verificar que los campos se inicializan correctamente
        assert_eq!(game.game_id, game_id, "El game_id deberia ser el esperado");
        assert_eq!(game.player_1, player_1_address, "El player_1 deberia ser la direccion del jugador 1");
        assert_eq!(game.player_2, ContractAddress::from(0), "El player_2 deberia estar inicializado en 0");
        assert_eq!(game.player_3, ContractAddress::from(0), "El player_3 deberia estar inicializado en 0");
        assert_eq!(game.player_4, ContractAddress::from(0), "El player_4 deberia estar inicializado en 0");
        assert_eq!(game.status, GameStatus::InProgress, "El estado deberia ser InProgress");
        assert_eq!(game.is_private, false, "El juego deberia ser publico por defecto");
    }

    #[test]
    fn test_player_2_joins_game() {
        // Crear direcciones de contrato de prueba
        let player_1_address = ContractAddress::from(1234_u32);
        let player_2_address = ContractAddress::from(5678_u32);
        let game_id = 98765432101234567890123456789012_u128;

        // Crear un juego con el jugador 1
        let mut game = Game::new(game_id, player_1_address);

        // Crear un jugador 2 con la dirección de contrato de prueba
        let player_2 = GamePlayer {
            address: player_2_address,
            game_id,
            beast_1: 0,
            beast_2: 0,
            beast_3: 0,
            beast_4: 0,
            bag_id: 0,
            active_mount: 0,
            mounts: ArrayTrait::new(),
            position: ArrayTrait::new(),
        };

        // Hacer que el jugador 2 se una al juego
        game.join_game(player_2);

        // Verificar que player_2 se haya unido al juego correctamente
        assert_eq!(game.player_2, player_2_address, "El player_2 deberia ser la direccion del jugador 2");
    }

    #[test]
    fn test_game_status_transition() {
        // Crear una dirección de contrato de prueba
        let player_1_address = ContractAddress::from(1234_u32);
        let game_id = 98765432101234567890123456789012_u128;

        // Crear el juego y verificar el estado inicial
        let mut game = Game::new(game_id, player_1_address);
        assert_eq!(game.status, GameStatus::InProgress, "El estado inicial deberia ser InProgress");

        // Cambiar el estado a Finished y verificar
        game.status = GameStatus::Finished;
        assert_eq!(game.status, GameStatus::Finished, "El estado deberia cambiar a Finished");
    }
}
