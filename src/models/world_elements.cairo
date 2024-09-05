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
