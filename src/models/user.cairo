use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct User {
    #[key]
    user_id: ContractAddress,
    name: ContractAddress,
}

