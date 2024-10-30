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

#[cfg(test)]
mod tests {
    use super::{MissionStatus, MissionStatusIntoFelt252};

    #[test]
    fn test_mission_status_into_felt252() {
        // Probar la conversión de cada estado de MissionStatus a felt252

        let not_started = MissionStatus::NotStarted;
        let in_progress = MissionStatus::InProgress;
        let completed = MissionStatus::Completed;
        let failed = MissionStatus::Failed;

        assert_eq!(not_started.into(), 0, "MissionStatus::NotStarted deberia convertirse a 0");
        assert_eq!(in_progress.into(), 1, "MissionStatus::InProgress deberia convertirse a 1");
        assert_eq!(completed.into(), 2, "MissionStatus::Completed deberia convertirse a 2");
        assert_eq!(failed.into(), 3, "MissionStatus::Failed deberia convertirse a 3");
    }
}
