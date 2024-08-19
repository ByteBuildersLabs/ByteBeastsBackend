use starknet::ContractAddress;

use bytebeasts::models::Beast;
use bytebeasts::models::Mt;
use bytebeasts::models::Player;
use bytebeasts::models::Potion;

#[dojo::interface]
trait IBattleActions {
    fn init_battle(ref world: IWorldDispatcher, player_id: u32, opponent_id: u32);
}

#[dojo::contract]
mod battle_system {
    use super::{IBattleActions};
    use starknet::{ContractAddress, get_caller_address};
    use bytebeasts::models::{Beast, Mt, Player, Potion};

    #[abi(embed_v0)]
    impl BattleActionsImpl of IBattleActions<ContractState> {
        fn init_battle(ref world: IWorldDispatcher, player_id: u32, opponent_id: u32) {
            let trainer = get!(world, player_id, (Player));
            let opponent = get!(world, opponent_id, (Player));
            let active_beast_player = get!(world, player_id, (Beast));
            let active_beast_opponent = get!(world, opponent_id, (Beast));
        }
    }
}
