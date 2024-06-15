// Credits to Cartridge - Roll Your Own: 
// Link https://github.com/cartridge-gg/rollyourown/blob/main/src/utils/random.cairo

use starknet::ContractAddress;
use starknet::{get_contract_address, get_block_timestamp};
use poseidon::poseidon_hash_span;

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[derive(Copy, Drop, Serde)]
struct Random {
    world: IWorldDispatcher,
    seed: felt252,
    nonce: usize,
}

#[generate_trait]
impl RandomImpl of RandomTrait {
    // one instance by contract, then passed by ref to sub fns
    fn new(world: IWorldDispatcher) -> Random {
        Random { world, seed: seed(), nonce: 0 }
    }

    fn next_seed(ref self: Random) -> felt252 {
        self.nonce += 1;
        self.seed = pedersen::pedersen(self.seed, self.nonce.into());
        self.seed
    }

    fn bool(ref self: Random) -> bool {
        let seed: u256 = self.next_seed().into();
        seed.low % 2 == 0
    }

    fn occurs(ref self: Random, likelihood: u8) -> bool {
        if likelihood == 0 {
            return false;
        }

        let result = self.between::<u8>(0, 100);
        result <= likelihood
    }

    fn between<
        T,
        +Into<T, u64>,
        +Into<T, u128>,
        +Into<T, u256>,
        +TryInto<u64, T>,
        +TryInto<u128, T>,
        +PartialOrd<T>,
        +Zeroable<T>,
        +Copy<T>,
        +Drop<T>
    >(
        ref self: Random, min: T, max: T
    ) -> T {
        let seed: u256 = self.next_seed().into();

        if min >= max {
            return Zeroable::zero();
        };

        let range: u128 = max.into() - min.into();
        let rand = (seed.low % range) + min.into();
        rand.try_into().unwrap()
    }
}

fn seed() -> felt252 {
    let mut data = array![];
    data.append(get_contract_address().into());
    data.append(get_block_timestamp().into());
    poseidon_hash_span(data.span())
}
