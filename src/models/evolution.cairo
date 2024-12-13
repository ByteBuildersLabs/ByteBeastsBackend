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


#[cfg(test)]
mod tests {
    use super::{Evolution, EvolutionTrait};
    use core::result::Result;

    #[test]
    fn test_evolution_with_valid_requirements() {

        let mut evolution = Evolution {
            base_beast_id: 1_u32,
            evolved_beast_id: 0_u32,
            level_requirement: 15_u32, 
            required_battles: 10_u32,  
            required_item: Option::Some(1001_u32) 
        };

        let result = evolution.evolve();

        match result {
            Result::Ok(evolved_id) => {
                assert(evolved_id == 10_u32, 'Incorrect evolution ID');
                assert(evolution.evolved_beast_id == 10_u32, 'Beast not evolved correctly');
            },
            Result::Err(_) => {
                panic!("Evolution should have succeeded")
            }
        }
    }

    #[test]
    fn test_evolution_with_invalid_level() {
       
        let mut evolution = Evolution {
            base_beast_id: 1_u32,
            evolved_beast_id: 0_u32,
            level_requirement: 5_u32,
            required_battles: 10_u32,
            required_item: Option::Some(1001_u32)
        };

        let result = evolution.evolve();

        match result {
            Result::Ok(_) => {
                panic!("Evolution should have failed due to low level")
            },
            Result::Err(e) => {
                assert(e == 'Evolution requirements not met', 'Unexpected error message');
            }
        }
    }

    #[test]
    fn test_evolution_with_invalid_battles() {
        
        let mut evolution = Evolution {
            base_beast_id: 1_u32,
            evolved_beast_id: 0_u32,
            level_requirement: 15_u32,
            required_battles: 3_u32, 
            required_item: Option::Some(1001_u32)
        };

        let result = evolution.evolve();
        match result {
            Result::Ok(_) => {
                panic!("Evolution should have failed due to insufficient battles")
            },
            Result::Err(e) => {
                assert(e == 'Evolution requirements not met', 'Unexpected error message');
            }
        }
    }

    #[test]
    fn test_evolution_with_invalid_item() {
       
        let mut evolution = Evolution {
            base_beast_id: 1_u32,
            evolved_beast_id: 0_u32,
            level_requirement: 15_u32,
            required_battles: 10_u32,
            required_item: Option::Some(999_u32) 
        };

        let result = evolution.evolve();
        match result {
            Result::Ok(_) => {
                panic!("Evolution should have failed due to wrong item")
            },
            Result::Err(e) => {
                assert(e == 'Evolution requirements not met', 'Unexpected error message');
            }
        }
    }

    #[test]
    fn test_evolution_with_no_item_requirement() {
       
        let mut evolution = Evolution {
            base_beast_id: 1_u32,
            evolved_beast_id: 0_u32,
            level_requirement: 15_u32,
            required_battles: 10_u32,
            required_item: Option::None 
        };

        let result = evolution.evolve();

        match result {
            Result::Ok(evolved_id) => {
                assert(evolved_id == 10_u32, 'Incorrect evolution ID');
            },
            Result::Err(_) => {
                panic!("Evolution should have succeeded without item requirement")
            }
        }
    }
}