use fuel_tx::{ContractId, Salt};
use fuels_abigen_macro::abigen;
use fuels_contract::{contract::Contract, parameters::TxParameters};
use fuels_signers::util::test_helpers;

// Load abi from json
abigen!(Storage, "test_projects/storage/out/debug/storage-abi.json");

async fn get_contract_instance() -> (Storage, ContractId) {
    // Deploy the compiled contract
    let salt = Salt::from([0u8; 32]);
    let compiled =
        Contract::load_sway_contract("test_projects/storage/out/debug/storage.bin", salt).unwrap();

    // Launch a local network and deploy the contract
    let (provider, wallet) = test_helpers::setup_test_provider_and_wallet().await;

    let id = Contract::deploy(&compiled, &provider, &wallet, TxParameters::default())
        .await
        .unwrap();

    let instance = Storage::new(id.to_string(), provider, wallet);

    (instance, id)
}

#[tokio::test]
async fn can_store_u64() {
    let (instance, _id) = get_contract_instance().await;
    let n = 42;
    instance.store_u64(n).call().await.unwrap();
    let result = instance.get_u64().call().await.unwrap();
    assert_eq!(result.value, n);
}