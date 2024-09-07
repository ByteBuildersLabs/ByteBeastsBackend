use bytebeasts::{
    models::{beast::Beast, mt::Mt, player::Player, battle::Battle, potion::Potion},
};

#[dojo::interface]
trait IBattleActions {
    fn init_battle(ref world: IWorldDispatcher, player_id: u32, opponent_id: u32) -> u32;
    fn check_flee_success(player_beast: Beast, opponent_beast: Beast) -> bool;
    fn calculate_damage(mt: Mt, attacker: Beast, defender: Beast) -> u32;
    fn opponent_turn(ref world: IWorldDispatcher, battle_id: u32);
    fn attack(ref world: IWorldDispatcher, battle_id: u32, mt_id: u32);
    fn use_potion(ref world: IWorldDispatcher, battle_id: u32, potion_id: u32);
    fn flee(ref world: IWorldDispatcher, battle_id: u32);
}

#[dojo::contract]
mod battle_system {
    use super::{IBattleActions};
    use bytebeasts::{
        models::{beast::Beast, mt::Mt, player::Player, battle::Battle, potion::Potion},
    };

    #[derive(Copy, Drop, Serde)]
    #[dojo::model]
    #[dojo::event]
    struct StatusBattle {
        #[key]
        battle_id: u32,
        message: felt252,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::model]
    #[dojo::event]
    struct Status {
        #[key]
        player_id: u32,
        message: felt252,
    }

    #[abi(embed_v0)]
    impl BattleActionsImpl of IBattleActions<ContractState> {
        fn init_battle(ref world: IWorldDispatcher, player_id: u32, opponent_id: u32) -> u32 {
            let player = get!(world, player_id, (Player));
            let opponent = get!(world, opponent_id, (Player));
            let active_beast_player = get!(world, player.beast_1, (Beast));
            let active_beast_opponent = get!(world, opponent.beast_1, (Beast));

            let battle_created_id = 1; // Hardcoded for now
            set!(
                world,
                (Battle {
                    battle_id: battle_created_id,
                    player_id: player_id,
                    opponent_id: opponent_id,
                    active_beast_player: active_beast_player.beast_id,
                    active_beast_opponent: active_beast_opponent.beast_id,
                    battle_active: 1,
                    turn: 0,
                })
            );

            let message = 'Battle started';
            emit!(world, (Status { player_id: player_id,  message: message }));

            emit!(world, (StatusBattle { battle_id: battle_created_id,  message: message }));

            return battle_created_id;
        }

        fn check_flee_success(player_beast: Beast, opponent_beast: Beast) -> bool {
            player_beast.level > opponent_beast.level 
        }  

        fn calculate_damage(mt: Mt, attacker: Beast, defender: Beast) -> u32 {
            let base_damage = mt.mt_power * attacker.attack / defender.defense;

            //TODO: extend with effectivity by type, randomness, etc
            let effective_damage = base_damage; 

            // TODO: investigate how can we make It random
            // let hit_chance = random_felt252() % 100_u32;

            let hit_chance = 80_u32; // Hardcoded for now
            if hit_chance > mt.mt_accuracy {
                return 0_u32; 
            }

            effective_damage
        }

        fn opponent_turn(ref world: IWorldDispatcher, battle_id: u32) {
            let mut battle = get!(world, battle_id, (Battle));

            let mut player_beast = get!(world, battle.active_beast_player, (Beast));
            let mut opponent_beast = get!(world, battle.active_beast_opponent, (Beast));
            let opponent_attack = get!(world, opponent_beast.mt1, (Mt));

            let damage = self.calculate_damage(opponent_attack, opponent_beast, player_beast);
            if damage >= player_beast.current_hp {
                player_beast.current_hp = 0;
            } else {
                player_beast.current_hp -= damage;
            }
            set!(world, (player_beast));

            if player_beast.current_hp <= 0_u32 {
                let message = 'Player Beast Knocked Out!';
                emit!(world, (StatusBattle { battle_id,  message }));
                battle.battle_active = 0;
                set!(world, (battle));
            }
        }

        fn attack(ref world: IWorldDispatcher, battle_id: u32, mt_id: u32) {
            let mut battle = get!(world, battle_id, (Battle));

            let player_beast = get!(world, battle.active_beast_player, (Beast));
            let mut opponent_beast = get!(world, battle.active_beast_opponent, (Beast));
            let mt = get!(world, mt_id, (Mt));

            let damage = self.calculate_damage(mt, player_beast, opponent_beast);

            if damage >= opponent_beast.current_hp {
                opponent_beast.current_hp = 0;
            } else {
                opponent_beast.current_hp -= damage;
            }
            set!(world, (opponent_beast));

            if opponent_beast.current_hp <= 0_u32 {
                let message = 'Opponent Beast Knocked Out!';
                emit!(world, (StatusBattle { battle_id,  message }));
                battle.battle_active = 0;
                set!(world, (battle));
            } else {
                let message = 'Attack Performed!';
                emit!(world, (StatusBattle { battle_id,  message }));
            }
        }

        fn use_potion(ref world: IWorldDispatcher, battle_id: u32, potion_id: u32) {
            let mut battle = get!(world, battle_id, (Battle));

            let mut player_beast = get!(world, battle.active_beast_player, (Beast));
            let potion = get!(world, potion_id, (Potion));

            if potion.potion_effect <= player_beast.current_hp {
                player_beast.current_hp += potion.potion_effect;
            }
            else {
                player_beast.current_hp = player_beast.hp;
            }

            set!(world, (player_beast));
            player_beast = get!(world, battle.active_beast_player, (Beast));

            let message = 'Item Used!';
            emit!(world, (StatusBattle { battle_id,  message }));
        }

        fn flee(ref world: IWorldDispatcher, battle_id: u32) {
            let mut battle = get!(world, battle_id, (Battle));

            let player_beast = get!(world, battle.active_beast_player, (Beast));
            let opponent_beast = get!(world, battle.active_beast_opponent, (Beast));

            let flee_success = self.check_flee_success(player_beast, opponent_beast);
            if flee_success {
                battle.battle_active = 0;
                set!(world, (battle));
                let message = 'Player Fled!';
                emit!(world, (StatusBattle { battle_id, message }));
            } else {
                let message = 'Flee failed!';
                emit!(world, (StatusBattle { battle_id,  message }));
            }
        }
    }
}
