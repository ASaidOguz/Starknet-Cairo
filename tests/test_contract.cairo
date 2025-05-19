
#[cfg(test)]


use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use nine_cairo::NineCairoInterfaceDispatcher;
use nine_cairo::NineCairoInterfaceDispatcherTrait;

// Declare and deploy the contract and return its dispatcher.
fn deploy(name: felt252) -> NineCairoInterfaceDispatcher {
    let contract = declare("NineCairo").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@array![name]).unwrap();

    // Return the dispatcher.
    // It allows to interact with the contract based on its interface.
    NineCairoInterfaceDispatcher { contract_address }
}

#[test]
fn test_deploy() {
    let name_felt: felt252 = 'Alice'.into();
    let contract = deploy(name_felt);
    
    assert(contract.name_get() == name_felt, 'Name does not match');
}

#[test]
fn test_invoke_call_correct(){
    let name_felt: felt252 = 'Ahmet'.into();
    let contract = deploy(name_felt);
    assert(contract.name_get() == name_felt, 'Name does not match');

    let new_name_felt:felt252='Alexander'.into();
    contract.name_set(new_name_felt);
    assert(contract.name_get() == new_name_felt, 'New Name does not match');
}


