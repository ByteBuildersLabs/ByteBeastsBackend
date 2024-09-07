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
}
