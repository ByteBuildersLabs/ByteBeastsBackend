use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Player {
    #[key]
    player_id: ContractAddress,
    name: felt252,
    picture: felt252 
}