use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct Beasts {
    #[key]
    player: ContractAddress,
    beastId: u8,
    name: ByteArray,
    health: u8,
    experience: u8,
    attack: u8,
    level: u8,
    beastType: BeastType,
}

#[derive(Serde, Copy, Drop, Introspect)]
enum BeastType {
    legandary,
    pseudoLegendary,
    normal,
    shinny,
}