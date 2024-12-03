use core::result::Result;

#[derive(Drop, Copy, Serde)]
#[dojo::model]
struct Evolution {
    #[key]
    pub base_beast_id: u32,
    pub evolved_beast_id: u32,
    pub level_requirement: u32,
    pub required_battles: u32,
    pub required_item: Option<u32>
}

mod rules {
    /// Minimum rules for beast evolution

    /// Minimum level required before evolution is possible
    const LEVEL_REQUIREMENT: u32 = 10;
    /// Minimum number of battles required before evolution
    const REQUIRED_BATTLES: u32 = 5;
    /// Item ID required for evolution (special evolution stone)
    const REQUIRED_ITEM: u32 = 1001;

}

#[generate_trait]
impl EvolutionImpl of EvolutionTrait {
    fn can_evolve(self: Evolution) -> bool {
        let is_valid_item: bool = match self.required_item {
            Option::Some(val) => val == rules::REQUIRED_ITEM,
            Option::None => true,
       };

        is_valid_item &&
            self.level_requirement > rules::LEVEL_REQUIREMENT &&
            self.required_battles > rules::REQUIRED_BATTLES
    }

    fn evolve(ref self: Evolution) -> Result<u32, felt252>  {
        assert(self.base_beast_id != 0, 'Invalid base beast');

        match self.can_evolve() {
            true => {
                // TODO: investigate how can we make It random
                self.evolved_beast_id =  self.base_beast_id * 10_u32;
                Result::Ok(self.evolved_beast_id)
            },
            false => Result::Err('Evolution requirements not met'),
        }
    }
}
