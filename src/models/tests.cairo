#[cfg(test)]
mod tests {
    use bytebeasts::models::battle::Battle;
    use bytebeasts::models::beast::{Beast, BeastTrait};
    use bytebeasts::models::player::Player;
    use bytebeasts::models::coordinates::Coordinates;
    use bytebeasts::models::position::Position;
    use bytebeasts::models::mt::Mt;
    use bytebeasts::models::potion::Potion;
    use bytebeasts::models::world_elements::WorldElements;

    #[test]
    fn test_beast_exist() {
        let beast = Beast {
            beast_id: 1,
            beast_name: 0,
            beast_type: WorldElements::Crystal,
            beast_description: 0,
            player_id: 1,
            hp: 100,
            current_hp: 100,
            attack: 50,
            defense: 40,
            mt1: 1, // Fire Blast
            mt2: 2, // Ember
            mt3: 3, // Flame Wheel
            mt4: 4, // Fire Punch
            level: 5,
            experience_to_next_level: 1000,
        };
        assert(beast.exist(), 'Beast is alive');
        assert_eq!(beast.hp, 100, "HP should be initialized to 100");
    }

    #[test]
    fn test_player_initialization() {
        let player = Player {
            player_id: 1,
            player_name: 'Hero',
            beast_1: 1,
            beast_2: 2,
            beast_3: 3,
            beast_4: 4,
            potions: 5,
        };

        assert_eq!(player.player_name, 'Hero', "Player name should be 'Hero'");
        assert_eq!(player.potions, 5, "Player should have 5 potions");
    }

    #[test]
    fn test_position_initialization() {
        let player = Player {
            player_id: 1,
            player_name: 'Hero',
            beast_1: 1,
            beast_2: 2,
            beast_3: 3,
            beast_4: 4,
            potions: 5,
        };

        let coordinates = Coordinates{
            x: 10,
            y: 10,
        };

        let position = Position {
            player: player,
            coordinates: coordinates
        };

        assert_eq!(position.player.player_id, 1, "Player ID should be 1");
        assert_eq!(position.coordinates.x, 10, "Player X coordinate should be 10");
        assert_eq!(position.coordinates.y, 10, "Player Y coordinate should be 10");
    }

    #[test]
    fn test_battle_initialization() {
        let battle = Battle {
            battle_id: 1,
            player_id: 1,
            opponent_id: 2,
            active_beast_player: 1,
            active_beast_opponent: 2,
            battle_active: 1,
            turn: 1,
        };

        assert_eq!(battle.battle_id, 1, "Battle ID should be 1");
        assert_eq!(battle.player_id, 1, "Player ID should be 1");
        assert_eq!(battle.opponent_id, 2, "Opponent ID should be 2");
        assert_eq!(battle.battle_active, 1, "Battle should be active");
        assert_eq!(battle.turn, 1, "Turn should be 1");
    }

    #[test]
    fn test_mt_initialization() {
        let mt = Mt {
            mt_id: 1,
            mt_name: 0, // Assume mt_name is felt252 type
            mt_type: WorldElements::Light,
            mt_power: 75,
            mt_accuracy: 90,
        };

        assert_eq!(mt.mt_id, 1, "MT ID should be 1");
        assert_eq!(mt.mt_power, 75, "MT power should be 75");
        assert_eq!(mt.mt_accuracy, 90, "MT accuracy should be 90");
    }

    #[test]
    fn test_potion_initialization() {
        let potion = Potion {
            potion_id: 1,
            potion_name: 0, // Assume potion_name is felt252 type
            potion_effect: 50, // Heals 50 HP
        };

        assert_eq!(potion.potion_id, 1, "Potion ID should be 1");
        assert_eq!(potion.potion_effect, 50, "Potion effect should be 50");
    }
}
