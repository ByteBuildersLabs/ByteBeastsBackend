use starknet::ContractAddress;
use bytebeasts::{
    models::{beast::Beast, mt::Mt, player::Player, battle::Battle, potion::Potion},
};


#[dojo::interface]
trait IBattleActions {
    fn check_flee_success(player_beast: Beast, opponent_beast: Beast) -> felt252;
    fn apply_item_effect(potion: Potion, target: Beast);
    fn calculate_damage(mt: Mt, attacker: Beast, defender: Beast) -> u32;
    fn opponent_turn(ref world: IWorldDispatcher, battle_id: u32);
    fn init_battle(ref world: IWorldDispatcher, player_id: u32, opponent_id: u32);
    fn attack(ref world: IWorldDispatcher, battle_id: u32, mt_id: u32);
    fn use_potion(ref world: IWorldDispatcher, battle_id: u32, potion_id: u32);
    fn flee(ref world: IWorldDispatcher, battle_id: u32);
}

#[dojo::contract]
mod battle_system {
    use super::{IBattleActions};
    use starknet::{ContractAddress, get_caller_address};
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
        // Función para comprobar si se ha conseguido huir
        fn check_flee_success(player_beast: Beast, opponent_beast: Beast) -> felt252 {
            if player_beast.level > opponent_beast.level {
                1 // Success
            } else {
                0 // Fail
            }
        }

        // Función para aplicar el efecto de una poción
        fn apply_item_effect(potion: Potion, mut target: Beast) {
            if potion.potion_effect == 1 {
                target.current_hp += 20_u32;
                if target.current_hp > target.hp {
                    target.current_hp = target.hp;
                }
            }
        }

        // Funcion para calcular el daño de un ataque
        fn calculate_damage(mt: Mt, attacker: Beast, defender: Beast) -> u32 {
            let base_damage = mt.mt_power * attacker.attack / defender.defense;

            // Aplicar efectividad y otros modificadores (simplificado)
            let effective_damage =
                base_damage; // Extender con efectividad por tipo, aleatoriedad, etc.

            // how can we make It random
            // let hit_chance = random_felt252() % 100_u32;

            let hit_chance = 50_u32; // Hardcoded for now
            if hit_chance > mt.mt_accuracy {
                return 0_u32; // Ataque fallido
            }

            effective_damage
        }

        // Lógica del turno del oponente
        fn opponent_turn(ref world: IWorldDispatcher, battle_id: u32) {
            let mut battle = get!(world, battle_id, (Battle));

            let mut player_beast = get!(world, battle.active_beast_player, (Beast));
            let opponent_beast = get!(world, battle.active_beast_opponent, (Beast));
            let opponent_attack = get!(world, opponent_beast.mt1, (Mt));

            let damage = self.calculate_damage(opponent_attack, opponent_beast, player_beast);
            player_beast.current_hp -= damage;

            if player_beast.current_hp <= 0_u32 {
                battle.battle_active = 0;
            }
        }

        // Función para inicializar una batalla
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
            let message = 'Battle started';
            emit!(world, (Status { player_id,  message }));
        }

        // Función para realizar una acción
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

            if opponent_beast.current_hp <= 0_u32 {
                let message = 'Opponent\'s Beast Knocked Out!';
                emit!(world, (StatusBattle { battle_id,  message }));
                battle.battle_active = 0;
            } else {
                let message = 'Attack Performed!';
                emit!(world, (StatusBattle { battle_id,  message }));
                self.opponent_turn(battle_id);
            }
        }

        // Función para usar una poción
        fn use_potion(ref world: IWorldDispatcher, battle_id: u32, potion_id: u32) {
            let mut battle = get!(world, battle_id, (Battle));

            let player_beast = get!(world, battle.active_beast_player, (Beast));
            let potion = get!(world, potion_id, (Potion));

            self.apply_item_effect(potion, player_beast);

            let message = 'Item Used!';
            emit!(world, (StatusBattle { battle_id,  message }));

            // Turno del oponente
            self.opponent_turn(battle_id);
        }

        // Función para huir
        fn flee(ref world: IWorldDispatcher, battle_id: u32) {
            let mut battle = get!(world, battle_id, (Battle));

            let player_beast = get!(world, battle.active_beast_player, (Beast));
            let opponent_beast = get!(world, battle.active_beast_opponent, (Beast));

            let flee_success = self.check_flee_success(player_beast, opponent_beast);
            if flee_success == 1 {
                battle.battle_active = 0;
                let message = 'Player Fled!';
                emit!(world, (StatusBattle { battle_id,  message }));
            } else {
                let message = 'Flee failed!';
                emit!(world, (StatusBattle { battle_id,  message }));
                self.opponent_turn(battle_id);
            }
        }
    }
}
