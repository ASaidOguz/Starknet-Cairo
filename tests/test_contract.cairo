
#[cfg(test)]


use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use nine_cairo::NineCairoInterfaceDispatcher;
use nine_cairo::NineCairoInterfaceDispatcherTrait;
use openzeppelin_utils::serde::SerializedAppend;

// Declare and deploy the contract and return its dispatcher.
fn deploy(name: ByteArray) -> NineCairoInterfaceDispatcher {
    let contract = declare("NineCairo").unwrap().contract_class();
    let name: ByteArray = "Ahmet";
    let mut calldata = array![];
    calldata.append_serde(name);

    let (contract_address, _) = contract.deploy(@calldata).unwrap();

    // Return the dispatcher.
    // It allows to interact with the contract based on its interface.
    NineCairoInterfaceDispatcher { contract_address }
}

#[test]
fn test_deploy() {
    let name_felt: ByteArray = "Ahmet";
    let contract = deploy(name_felt.clone());
    
    assert(contract.name_get() == name_felt, 'Name does not match');
}

#[test]
fn test_invoke_call_correct(){
    let name_felt: ByteArray = "Ahmet";
    let contract = deploy(name_felt.clone());
    assert(contract.name_get() == name_felt, 'Name does not match');

    let new_name_felt:ByteArray="Alexander";
    contract.name_set(new_name_felt.clone());
    assert(contract.name_get() == new_name_felt, 'New Name does not match');
}


// You use @ when:

// The function expects ownership, not a reference

// You’re working with a type that doesn't implement Copy

// You’re okay not using the variable again

// Use @ when you want to move ownership, and you won’t reuse the variable.

// Use .clone() when you need the variable again after using it.