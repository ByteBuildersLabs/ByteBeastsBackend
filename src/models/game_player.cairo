use starknet::ContractAddress;

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

#[cfg(test)]
mod tests {
    use super::{GamePlayer, GamePlayerTrait};
    use starknet::ContractAddress;

    #[test]
    fn test_game_player_initialization() {
        // Crear una dirección de contrato de prueba
        let address = ContractAddress::from(1234_u32);
        let game_id = 98765432101234567890123456789012_u128;

        // Crear un jugador usando el método `new`
        let game_player = GamePlayer::new(game_id, address);

        // Verificar que los campos se inicializan correctamente
        assert_eq!(game_player.address, address, "La direccion deberia ser la esperada");
        assert_eq!(game_player.game_id, game_id, "El game_id deberia ser el esperado");
        assert_eq!(game_player.beast_1, 0_u8, "El beast_1 deberia inicializarse en 0");
        assert_eq!(game_player.beast_2, 0_u8, "El beast_2 deberia inicializarse en 0");
        assert_eq!(game_player.beast_3, 0_u8, "El beast_3 deberia inicializarse en 0");
        assert_eq!(game_player.beast_4, 0_u8, "El beast_4 deberia inicializarse en 0");
        assert_eq!(game_player.bag_id, 0_u8, "El bag_id deberia inicializarse en 0");
        assert_eq!(game_player.active_mount, 0_u8, "El active_mount deberia inicializarse en 0");

        // Verificar que los arrays de mounts y position estén vacíos al inicio
        assert!(game_player.mounts.is_empty(), "El array de mounts deberia estar vacio");
        assert!(game_player.position.is_empty(), "El array de position deberia estar vacio");
    }

    #[test]
    fn test_game_player_custom_initialization() {
        // Prueba con valores de juego personalizados
        let address = ContractAddress::from(4321_u32);
        let game_id = 12345678901234567890123456789012_u128;

        // Crear un jugador con valores personalizados
        let game_player = GamePlayer::new(game_id, address);

        // Validar los valores personalizados
        assert_eq!(game_player.address, address, "La direccion deberia coincidir con la direccion personalizada");
        assert_eq!(game_player.game_id, game_id, "El game_id deberia coincidir con el valor personalizado");
    }
}
