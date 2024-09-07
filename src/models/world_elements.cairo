#[derive(Serde, Copy, Drop, Introspect)]
pub enum WorldElements {
    Crystal,
    Draconic,
    Shadow,
    Light,
    Titanium,
}

impl WorldElementsIntoFelt252 of Into<WorldElements, felt252> {
    fn into(self: WorldElements) -> felt252 {
        match self {
            WorldElements::Crystal => 0,
            WorldElements::Draconic => 1,
            WorldElements::Shadow => 2,
            WorldElements::Light => 3,
            WorldElements::Titanium => 4,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::WorldElements;

    #[test]
    fn test_world_elements_to_felt252() {
        // Verificar que cada variante de WorldElements se convierta correctamente en el valor felt252 esperado
        let crystal: felt252 = WorldElements::Crystal.into();
        let draconic: felt252 = WorldElements::Draconic.into();
        let shadow: felt252 = WorldElements::Shadow.into();
        let light: felt252 = WorldElements::Light.into();
        let titanium: felt252 = WorldElements::Titanium.into();

        // Comprobar los valores
        assert_eq!(crystal, 0, "Crystal deberia convertirse a 0");
        assert_eq!(draconic, 1, "Draconic deberia convertirse a 1");
        assert_eq!(shadow, 2, "Shadow deberia convertirse a 2");
        assert_eq!(light, 3, "Light deberia convertirse a 3");
        assert_eq!(titanium, 4, "Titanium deberia convertirse a 4");
    }

    #[test]
    fn test_world_elements_equality() {
        // Verificar la igualdad entre las variantes del enum
        assert_eq!(WorldElements::Crystal, 0, "Crystal deberia ser igual a 0",);
        assert_eq!(WorldElements::Draconic, 1, "Draconic deberia ser igual a 1",);
        assert_eq!(WorldElements::Shadow, 2, "Shadow deberia ser igual a 2",);
        assert_eq!(WorldElements::Light, 3, "Light deberia ser igual a 3",);
        assert_eq!(WorldElements::Titanium, 4, "Titanium deberia ser igual a 4",);
    }

    #[test]
    fn test_world_elements_conversion_back() {
        // Verificar una conversión inversa si fuera relevante
        let crystal_value: felt252 = 0;
        let draconic_value: felt252 = 1;
        
        // Puedes implementar lógica que permita convertir el valor de vuelta al enum, si es necesario
        // Aquí dejamos los assert de cómo podrías mapear hacia atrás en algún momento.
        // assert_eq!(felt_to_world_element(crystal_value), WorldElements::Crystal);
        // assert_eq!(felt_to_world_element(draconic_value), WorldElements::Draconic);
    }
}
