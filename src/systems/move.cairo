use bytebeasts::{
    models::{player::Player, coordinates::Coordinates, position::Position},
};

#[dojo::interface]
trait IMoveAction {
    fn move(ref world: IWorldDispatcher, player_id: u32, new_x: u32, new_y: u32);
}

#[dojo::contract]
mod move_action {
    use super::IMoveAction;
    use starknet::{ContractAddress, get_caller_address};
    use bytebeasts::{
        models::{player::Player, coordinates::Coordinates, position::Position},
    };

    #[abi(embed_v0)]
    impl MoveActionImpl of IMoveAction<ContractState> {
        fn move(ref world: IWorldDispatcher, player_id: u32, new_x: u32, new_y: u32) {
            let player_from_world = get!(world, player_id, (Player));

            set!(
                world,
                (
                    Position {
                        player: player_from_world, coordinates: Coordinates { x: new_x, y: new_y }
                    },
                )
            );
        }
    }
}