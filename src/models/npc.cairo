use super::role::Role;
use super::coordinates::Coordinates;
use super::mission_status::MissionStatus;
use super::potion::Potion;

use array::ArrayTrait; 

#[derive(Drop, Serde)]
#[dojo::model]
pub struct NPC {
    #[key]
    pub npc_id: u32, // Unique identifier for the NPC
    pub npc_name: felt252, // Name of the NPC
    pub npc_description: felt252, // Description of the NPC
    pub npc_role: Role, // Role of the NPC, defined by the Role enum
    pub dialogue: ByteArray, // Default dialogue for the NPC
    pub is_active: bool, // Whether the NPC is currently active in the game
    pub location: Coordinates, // Fixed location of the NPC on the map
    pub importance_level: u8, // Level of importance of the NPC in the game
    pub mission_status: MissionStatus, // Status of the mission associated with the NPC
    pub reward: u16, // Fixed reward given by the NPC
    pub experience_points: u16, // Experience points given by the NPC
    pub potions: Array<Potion>, // Items held by the NPC
}


#[cfg(test)]
mod tests {
    use bytebeasts::{
        models::{role::Role, coordinates::Coordinates, mission_status::MissionStatus, npc::NPC, potion::Potion},
    };
    use array::ArrayTrait; 

    #[test]
    fn test_npc_creation() {
        let mut npc = NPC {
            npc_id: 1,
            npc_name: 'Gandalf',
            npc_description: 'A wise old wizard',
            npc_role: Role::Guide,
            dialogue: "Welcome to Middle-earth!",
            is_active: true,
            location: Coordinates { x: 100, y: 200 },
            importance_level: 5,
            mission_status: MissionStatus::NotStarted,
            reward: 50,
            experience_points: 100,
            potions: ArrayTrait::new(),
        };
        let potion = Potion {
            potion_id: 1,
            potion_name: 'Restore everything',
            potion_effect: 50,
        };

        npc.potions.append(potion);

        assert_eq!(npc.npc_id, 1);
        assert_eq!(npc.npc_name, 'Gandalf');
        assert_eq!(npc.npc_description, 'A wise old wizard');
        assert_eq!(npc.npc_role.into(), 2); // Role::Guide -> 2
        assert!(npc.is_active);
        assert_eq!(npc.location.x, 100);
        assert_eq!(npc.location.y, 200);
        assert_eq!(npc.importance_level, 5);
        assert_eq!(npc.mission_status.into(), 0); // MissionStatus::NotStarted -> 0
        assert_eq!(npc.reward, 50);
        assert_eq!(npc.experience_points, 100);
        assert_eq!(npc.potions.len(), 1, "NPC should have 1 potion");
        assert_eq!(npc.potions.pop_front().unwrap().potion_id, 1, "NPC potion ID should be 1");
    }

    #[test]
    fn test_npc_role_conversion() {
        let role_guide: felt252 = Role::Guide.into();
        assert_eq!(role_guide, 2);

        let role_vendor: felt252 = Role::Vendor.into();
        assert_eq!(role_vendor, 0);
    }

    #[test]
    fn test_mission_status_conversion() {
        let status_in_progress: felt252 = MissionStatus::InProgress.into();
        assert_eq!(status_in_progress, 1);

        let status_completed: felt252 = MissionStatus::Completed.into();
        assert_eq!(status_completed, 2);
    }
}
