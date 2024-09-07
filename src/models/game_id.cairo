#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct GameId {
    #[key]
    pub id: u32,
    pub game_id: u128
}

#[cfg(test)]
mod tests {
    use super::GameId;

    #[test]
    fn test_game_id_initialization() {
        // Crear una instancia de GameId
        let game_id = GameId { id: 1, game_id: 12345678901234567890123456789012 };

        // Verificar que los valores se inicializan correctamente
        assert_eq!(game_id.id, 1, "El valor de id deberia ser 1");
        assert_eq!(game_id.game_id, 12345678901234567890123456789012, "El valor de game_id deberia ser el esperado");
    }

    #[test]
    fn test_game_id_equality() {
        // Crear dos instancias de GameId con los mismos valores
        let game_id1 = GameId { id: 2, game_id: 98765432109876543210987654321098 };
        let game_id2 = GameId { id: 2, game_id: 98765432109876543210987654321098 };

        // Verificar que las instancias con los mismos valores son iguales
        assert_eq!(game_id1.id, game_id2.id, "Los valores de id deberian ser iguales");
        assert_eq!(game_id1.game_id, game_id2.game_id, "Los valores de game_id deberian ser iguales");
    }

    #[test]
    fn test_game_id_copy() {
        // Verificar que la estructura puede copiarse correctamente
        let game_id1 = GameId { id: 3, game_id: 11111111111111111111111111111111 };
        let game_id2 = game_id1; // Como la estructura implementa `Copy`, esto debería funcionar

        assert_eq!(game_id2.id, 3, "El valor de id en game_id2 deberia ser 3");
        assert_eq!(game_id2.game_id, 11111111111111111111111111111111, "El valor de game_id en game_id2 deberia ser el esperado");
    }

    #[test]
    fn test_game_id_invalid() {
        // Crear una instancia con un valor de id inesperado
        let game_id = GameId { id: 0, game_id: 12345678901234567890123456789012 };

        // Verificar que no cumple ciertas condiciones (puedes adaptar según la lógica de tu aplicación)
        assert_ne!(game_id.id, 1, "El valor de id no deberia ser 1");
        assert_eq!(game_id.game_id, 12345678901234567890123456789012, "El valor de game_id deberia ser el esperado");
    }
}
