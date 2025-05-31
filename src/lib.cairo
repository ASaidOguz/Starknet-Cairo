// ** ./src/lib.cairo **
///MyContractInterface
#[starknet::interface]
pub trait NineCairoInterface<T> {
    fn name_get(self: @T) -> ByteArray;
    fn name_set(ref self: T, name: ByteArray);
}

#[starknet::contract]
pub mod NineCairo {
   
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    
    #[storage]
    struct Storage {
        name: ByteArray,
    }
   
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        NameChanged: NameChanged,
    }

    #[derive(Drop, starknet::Event)]
    struct NameChanged {
        previous: ByteArray,
        current: ByteArray,
    }

    #[constructor]
    fn constructor(ref self: ContractState, name: ByteArray) {
        self.name.write(name);
    }

    #[abi(embed_v0)]
    impl NineCairo of super::NineCairoInterface<ContractState> {
        fn name_get(self: @ContractState) -> ByteArray {
            self.name.read()
        }

        fn name_set(ref self: ContractState, name: ByteArray) {
            let previous = self.name.read();
            self.name.write(name.clone());
            self.emit(NameChanged { previous, current: name });
        }
    }
}

// These types implement Copy, so moving them doesn’t invalidate the original — they are implicitly copied:

// Type	Description
// felt252	Basic field element (like int)
// bool	Boolean value
// u8, u16, u32, u64	Unsigned integers
// ContractAddress	Contract address (as of now)
// Structs with #[derive(Copy, Drop)]	You mark them to be Copy
