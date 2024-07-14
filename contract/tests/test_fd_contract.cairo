use astral_zkml::math;
use astral_zkml::math::signed::{
    I128SignedBasics, unsigned_to_signed, felt_to_i128, I128Div, I128Display,
};
use astral_zkml::math::wfloat::{
    WFloat, WFloatBasics, ZERO_WFLOAT, ONE_WFLOAT, NEG_WFLOAT, HALF_WFLOAT, DECIMAL_WFLOAT,
};
use astral_zkml::math::vector::{Vector, VectorBasics};
use astral_zkml::math::matrix::{Matrix, MatrixBasics};
use astral_zkml::contract::fully_decentralized_contract::{
    FullyDecentralizedContract, IFullyDecentralizedContractDispatcher,
    IFullyDecentralizedContractDispatcherTrait
};

use starknet::syscalls::deploy_syscall;
use starknet::ContractAddress;

// ------------------------------------------------------------------------------------

fn util_felt_addr(addr_felt: felt252) -> ContractAddress {
    addr_felt.try_into().unwrap()
}

fn deploy_contract() -> IFullyDecentralizedContractDispatcher {
    let calldata: Span<felt252> = array![].span();

    let (address0, _) = deploy_syscall(
        FullyDecentralizedContract::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata, false
    )
        .unwrap();
    let contract0 = IFullyDecentralizedContractDispatcher { contract_address: address0 };

    contract0
}

#[ignore]
#[test]
fn check_contract() -> () {
    let _dispatcher: IFullyDecentralizedContractDispatcher = deploy_contract();

    let _admin_0 = util_felt_addr('Akashi');
    let _admin_1 = util_felt_addr('Ozu');
    let _admin_2 = util_felt_addr('Higuchi');

    starknet::testing::set_contract_address(_admin_0);

//     // -------------------------------------------------------------------

//     let rawX = array![].span();
//     let rawY = array![].span();

//     let X = MatrixBasics::from_raw_felt(@rawX);
//     let Y = MatrixBasics::from_raw_felt(@rawY);

//     // -------------------------------------------------------------------

//     let result = dispatcher.predict(rawX, false);
//     println!("result : \n{result}");
//     println!("wanted : \n{Y}");
// // -------------------------------------------------------------------

}
