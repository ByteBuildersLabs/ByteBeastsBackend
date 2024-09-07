#[derive(Drop, Copy, Serde, Introspect)]
struct Coordinates {
    x: u32,
    y: u32
}

#[cfg(test)]
mod tests {
    use super::Coordinates;

    #[test]
    fn test_coordinates_initialization() {
        // Crear una instancia de Coordinates
        let coord = Coordinates { x: 10, y: 20 };

        // Verificar que los valores se inicializan correctamente
        assert_eq!(coord.x, 10, "El valor de x deberia ser 10");
        assert_eq!(coord.y, 20, "El valor de y deberia ser 20");
    }

    #[test]
    fn test_coordinates_equality() {
        // Crear dos instancias de Coordinates
        let coord1 = Coordinates { x: 5, y: 15 };
        let coord2 = Coordinates { x: 5, y: 15 };

        // Verificar que dos coordenadas iguales son comparables correctamente
        assert_eq!(coord1.x, coord2.x, "Las coordenadas x deberian ser iguales");
        assert_eq!(coord1.y, coord2.y, "Las coordenadas y deberian ser iguales");
    }

    #[test]
    fn test_coordinates_copy() {
        // Verificar que la estructura puede copiarse correctamente
        let coord1 = Coordinates { x: 30, y: 40 };
        let coord2 = coord1; // Como la estructura implementa `Copy`, esto debería funcionar

        assert_eq!(coord2.x, 30, "El valor de x en coord2 deberia ser 30");
        assert_eq!(coord2.y, 40, "El valor de y en coord2 deberia ser 40");
    }
}
