use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// How are going to define If a beast is legendary or not?
#[derive(Serde, Copy, Drop, PartialEq)]
enum BeastType {
    Crystal,
    Draconic,
    Shadow,
    Titanium,
    Light,
}

#[derive(Model, Copy, Drop, Serde)]
struct Beast {
    #[key]
    beast_id: u32,
    beast_type: u8,
    hp: u64,
    attack: u64,
    movement_range: u64,
}

trait BeastTrait {
    fn new(beast_type: BeastType) -> Beast;
}

impl BeastImpl of BeastTrait {
    fn new(beast_type: BeastType) -> Beast {
        let beast = match beast_type {
            BeastType::Crystal => create_crystal(beast_type.into()),
            BeastType::Draconic => create_draconic(beast_type.into()),
            BeastType::Shadow => create_shadow(beast_type.into()),
            BeastType::Titanium => create_titanium(beast_type.into()),
            BeastType::Light => create_light(beast_type.into()),
        };
        beast
    }
}

fn create_crystal(id: u32) -> Beast {
    Beast {
        beast_id: id,
        beast_type: BeastType::Crystal.into(),
        hp: 250,
        attack: 15,
        movement_range: 6,
    }
}

fn create_draconic(id: u32) -> Beast {
    Beast {
        beast_id: id,
        beast_type: BeastType::Draconic.into(),
        hp: 200,
        attack: 5,
        movement_range: 4,
    }
}

fn create_shadow(id: u32) -> Beast {
    Beast {
        beast_id: id,
        beast_type: BeastType::Shadow.into(),
        hp: 300,
        attack: 20,
        movement_range: 5,
    }
}

fn create_titanium(id: u32) -> Beast {
    Beast {
        beast_id: id,
        beast_type: BeastType::Titanium.into(),
        hp: 300,
        attack: 20,
        movement_range: 5,
    }
}

fn create_light(id: u32) -> Beast {
    Beast {
        beast_id: id,
        beast_type: BeastType::Light.into(),
        hp: 300,
        attack: 20,
        movement_range: 5,
    }
}

// Converters
impl BeastTypeIntoU8 of Into<BeastType, u8> {
    #[inline(always)]
    fn into(self: BeastType) -> u8 {
        match self {
            BeastType::Crystal => 1,
            BeastType::Draconic => 2,
            BeastType::Shadow => 3,
            BeastType::Titanium => 4,
            BeastType::Light => 5,
        }
    }
}

impl BeastTypeIntoU32 of Into<BeastType, u32> {
    #[inline(always)]
    fn into(self: BeastType) -> u32 {
        match self {
            BeastType::Crystal => 1,
            BeastType::Draconic => 2,
            BeastType::Shadow => 3,
            BeastType::Titanium => 4,
            BeastType::Light => 5,
        }
    }
}
