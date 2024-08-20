use starknet::ContractAddress;

use bytebeasts::models::Beast;
use bytebeasts::models::Mt;
use bytebeasts::models::Player;
use bytebeasts::models::Potion;
use bytebeasts::models::Battle;

#[dojo::interface]
trait IBattleActions {
    fn init_battle(ref world: IWorldDispatcher, player_id: u32, opponent_id: u32);
    fn check_flee_success(player_beast: Beast, opponent_beast: Beast) -> felt252;
}

#[dojo::contract]
mod battle_system {
    use super::{IBattleActions};
    use starknet::{ContractAddress, get_caller_address};
    use bytebeasts::models::{Beast, Mt, Player, Potion, Battle};

    #[abi(embed_v0)]
    impl BattleActionsImpl of IBattleActions<ContractState> {
        fn init_battle(ref world: IWorldDispatcher, player_id: u32, opponent_id: u32) {
            let player = get!(world, player_id, (Player));
            let opponent = get!(world, opponent_id, (Player));
            let active_beast_player = get!(world, player.beast_1, (Beast));
            let active_beast_opponent = get!(world, opponent.beast_1, (Beast));

            set!(
                world,
                (Battle {
                    battle_id: 1,
                    player_id: player_id,
                    opponent_id: opponent_id,
                    active_beast_player: active_beast_player.beast_id,
                    active_beast_opponent: active_beast_opponent.beast_id,
                    battle_active: 1,
                    turn: 0,
                })
            );
            // Try to send a message to the player (emit)
        }

        fn check_flee_success(player_beast: Beast, opponent_beast: Beast) -> felt252 {
          if player_beast.level > opponent_beast.level {
              1 // Success
          } else {
              0 // Fail
          }
      }
    }
}
