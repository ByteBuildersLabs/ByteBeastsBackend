#[derive(Serde, Copy, Drop, Introspect)]
pub enum MissionStatus {
    NotStarted,
    InProgress,
    Completed,
    Failed,
}

impl MissionStatusIntoFelt252 of Into<MissionStatus, felt252> {
    fn into(self: MissionStatus) -> felt252 {
        match self {
            MissionStatus::NotStarted => 0,
            MissionStatus::InProgress => 1,
            MissionStatus::Completed => 2,
            MissionStatus::Failed => 3,
        }
    }
}
