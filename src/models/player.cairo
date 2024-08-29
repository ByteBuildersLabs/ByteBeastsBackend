#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Player {
    #[key]
    pub player_id: u32,
    pub player_name: felt252,
    pub beast_1: u32,
    pub beast_2: u32,
    pub beast_3: u32,
    pub beast_4: u32,
    pub potions: u32,
}