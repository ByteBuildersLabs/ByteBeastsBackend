use bytebeasts::{
    models::{player::Player, coordinates::Coordinates, position::Position},
};

#[dojo::interface]
trait ISpawnAction {
    fn spawn(ref world: IWorldDispatcher, player_id: u32);
}

#[dojo::contract]
mod spawn_action {
    use super::ISpawnAction;
    use starknet::{ContractAddress, get_caller_address};
    use bytebeasts::{
        models::{player::Player, coordinates::Coordinates, position::Position},
    };

    #[abi(embed_v0)]
    impl SpawnActionImpl of ISpawnAction<ContractState> {
        fn spawn(ref world: IWorldDispatcher, player_id: u32) {
            let player_from_world = get!(world, player_id, (Player));

            set!(
                world,
                (Position { player: player_from_world, coordinates: Coordinates { x: 10, y: 10 } },)
            );
        }
    }
}