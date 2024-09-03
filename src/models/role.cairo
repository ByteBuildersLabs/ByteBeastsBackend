#[derive(Serde, Copy, Drop, Introspect)]
pub enum Role {
    Vendor,
    Trainer,
    Guide,
    QuestGiver,
}

impl RoleIntoFelt252 of Into<Role, felt252> {
    fn into(self: Role) -> felt252 {
        match self {
            Role::Vendor => 0,
            Role::Trainer => 1,
            Role::Guide => 2,
            Role::QuestGiver => 3,
        }
    }
}