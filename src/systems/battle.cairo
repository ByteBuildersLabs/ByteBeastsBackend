use starknet::ContractAddress;
use starknet::felt252;

// Importar los modelos
use bytebeasts::models::Beast;
use bytebeasts::models::Mt;
use bytebeasts::models::Player;
use bytebeasts::models::Potion;

// Definir la interfaz
#[dojo::interface]
trait IBattleActions {
    fn attack(ref world: IWorldDispatcher, mt_id: u32);
    fn use_potion(ref world: IWorldDispatcher, potion_id: u32);
    fn flee(ref world: IWorldDispatcher);
    fn init_battle(ref world: IWorldDispatcher, player_id: u32, opponent_id: u32);
}

// Decorador de Dojo
#[dojo::contract]
mod battle_system {
    use super::{IBattleActions};
    use starknet::{ContractAddress, get_caller_address};
    use bytebeasts::models::{Beast, Mt, Player, Potion};

    // Evento para registrar el estado de la batalla
    #[event]
    func BattleStatus(status: felt252) {
    }

    #[abi(embed_v0)]
    impl BattleActionsImpl of IBattleActions<ContractState> {
        
        // Inicializar el sistema de batalla
        fn init_battle(ref world: IWorldDispatcher, player_id: u32, opponent_id: u32) {
            let player = Player::get(player_id);
            let opponent = Player::get(opponent_id);

            // Establecer las bestias activas (suponiendo que beast_1 es la activa)
            let active_beast_player = Beast::get(player.beast_1);
            let active_beast_opponent = Beast::get(opponent.beast_1);

            // Configurar el estado de la batalla
            set!(
                world,
                (
                    player: player_id,
                    opponent: opponent_id,
                    active_beast_player: active_beast_player,
                    active_beast_opponent: active_beast_opponent,
                    battle_active: 1  // 1: activo, 0: inactivo
                )
            );

            BattleStatus.emit('Battle Started');
        }

        // Función para realizar una acción
        fn attack(ref world: IWorldDispatcher, mt_id: u32) {
            let player = get_caller_address();
            let player_id = get_player_id(world, player);
            let opponent_id = get_opponent_id(world);

            let player_beast = Beast::get(get_active_beast(world, player_id));
            let opponent_beast = Beast::get(get_active_beast(world, opponent_id));
            let mt = Mt::get(mt_id);

            let damage = calculate_damage(mt, player_beast, opponent_beast);
            opponent_beast.current_hp -= damage;

            if opponent_beast.current_hp <= 0_u32 {
                BattleStatus.emit('Opponent\'s Beast Knocked Out!');
                // Lógica para manejar la victoria o cambio de bestias del oponente
                set_battle_status(world, 0);  // Terminar la batalla
            } else {
                BattleStatus.emit('Attack Performed');
                // Turno del oponente
                opponent_turn(world);
            }
        }

        // Función para usar un ítem
        fn use_potion(ref world: IWorldDispatcher, potion_id: u32) {
            let player = get_caller_address();
            let player_id = get_player_id(world, player);
            let active_beast = Beast::get(get_active_beast(world, player_id));
            let potion = Potion::get(potion_id);

            apply_item_effect(potion, active_beast);

            BattleStatus.emit('Item Used');
            // Turno del oponente
            opponent_turn(world);
        }

        // Función para huir
        fn flee(ref world: IWorldDispatcher) {
            let player = get_caller_address();
            let player_id = get_player_id(world, player);
            let opponent_id = get_opponent_id(world);

            let player_beast = Beast::get(get_active_beast(world, player_id));
            let opponent_beast = Beast::get(get_active_beast(world, opponent_id));

            let flee_success = check_flee_success(player_beast, opponent_beast);
            if flee_success == 1 {
                set_battle_status(world, 0);  // Terminar la batalla
                BattleStatus.emit('Player Fled');
            } else {
                BattleStatus.emit('Flee Failed');
                // Turno del oponente
                opponent_turn(world);
            }
        }

        // Función para calcular el daño
        fn calculate_damage(mt: Mt, attacker: Beast, defender: Beast) -> u32 {
            let base_damage = mt.mt_power * attacker.attack / defender.defense;

            // Aplicar efectividad y otros modificadores (simplificado)
            let effective_damage = base_damage; // Extender con efectividad por tipo, aleatoriedad, etc.

            // Considerar precisión (simplificado)
            let hit_chance = random_felt252() % 100_u32;
            if hit_chance > mt.mt_accuracy {
                return 0_u32; // Ataque fallido
            }

            effective_damage
        }

        // Función para aplicar el efecto de un ítem
        fn apply_item_effect(potion: Potion, target: Beast) {
            // Aplicación simplificada del efecto (e.g., curar HP)
            if potion.potion_effect == 1 {
                target.current_hp += 20_u32; // Cantidad de curación de ejemplo
                if target.current_hp > target.hp {
                    target.current_hp = target.hp; // Limitar HP al máximo
                }
            }
        }

        // Función para verificar el éxito de huir
        fn check_flee_success(player_beast: Beast, opponent_beast: Beast) -> felt252 {
            if player_beast.level > opponent_beast.level {
                1 // Éxito al huir
            } else {
                0 // Fallo al huir
            }
        }

        // Lógica del turno del oponente
        fn opponent_turn(ref world: IWorldDispatcher) {
            let opponent_id = get_opponent_id(world);
            let player_id = get_player_id(world, get_caller_address());

            let active_beast_opponent = Beast::get(get_active_beast(world, opponent_id));
            let active_beast_player = Beast::get(get_active_beast(world, player_id));

            let opponent_attack = active_beast_opponent.mt1; // Suponiendo que el oponente siempre usa el primer movimiento
            let mt = Mt::get(opponent_attack);
            let damage = calculate_damage(mt, active_beast_opponent, active_beast_player);
            active_beast_player.current_hp -= damage;

            if active_beast_player.current_hp <= 0_u32 {
                BattleStatus.emit('Player\'s Beast Knocked Out!');
                set_battle_status(world, 0); // Terminar la batalla
            }
        }

        // Función para obtener el ID del jugador
        fn get_player_id(world: IWorldDispatcher, player_address: ContractAddress) -> u32 {
            // Implementar lógica para obtener el ID del jugador usando el mundo
        }

        // Función para obtener el ID del oponente
        fn get_opponent_id(world: IWorldDispatcher) -> u32 {
            // Implementar lógica para obtener el ID del oponente usando el mundo
        }

        // Función para obtener la bestia activa
        fn get_active_beast(world: IWorldDispatcher, player_id: u32) -> u32 {
            // Implementar lógica para obtener la bestia activa usando el mundo
        }

        // Función para establecer el estado de la batalla
        fn set_battle_status(world: IWorldDispatcher, status: u32) {
            // Implementar lógica para actualizar el estado de la batalla en el mundo
        }
    }
}
