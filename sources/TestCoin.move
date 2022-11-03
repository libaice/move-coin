module NBCOIN::TestCoin{
    use std::signer;
    use std::string;

    struct Coin has store {
        value : u128,
    }

    struct CoinStore has key {
        coin : Coin,
    }

    struct CoinInfo has key {
        // name
        name: string::String,
        // symbol
        symbol: string::String,
        // decimals
        decimals: u8,
        // suppley
        supply: u128,
        // capcity
        cap: u128,
    }

    /// Address of the owner of this module
    const MODULE_OWNER: address = @NBCOIN;

    const THE_ACCOUNT_HAS_BEEN_REGISTERED : u64 = 1;

    const INVALID_TOKEN_OWNER : u64 = 2;

    const THE_ACCOUNT_IS_NOT_REGISTERED : u64 = 3;

    const INSUFFICIENT_BALANCE : u64 = 4;

    const ECOIN_INFO_ALREADY_PUBLISHED : u64 = 5;

    const EXCEEDING_THE_TOTAL_SUPPLY : u64 = 6;

    public fun getBalance(owner: address) : u128 acquires CoinStore{

        assert!(is_account_registered(owner), THE_ACCOUNT_IS_NOT_REGISTERED);

        borrow_global<CoinStore>(owner).coin.value
    }


    public fun is_account_registered(account_addr : address) : bool{
        exists<CoinStore>(account_addr)
    }

    fun deposit(account_addr : address, coin : Coin) acquires CoinStore {

        assert!(is_account_registered(account_addr), THE_ACCOUNT_IS_NOT_REGISTERED);

        let balance = getBalance(account_addr);

        let balance_ref = &mut borrow_global_mut<CoinStore>(account_addr).coin.value;

        *balance_ref = balance + coin.value;

        let Coin { value:_ } = coin;
    }

    fun withdraw(account_addr : address, amount : u128) : Coin acquires CoinStore {
        assert!(is_account_registered(account_addr), THE_ACCOUNT_IS_NOT_REGISTERED);
        let balance = getBalance(account_addr);

        assert!(balance >= amount, INSUFFICIENT_BALANCE);

        let balance_ref = &mut borrow_global_mut<CoinStore>(account_addr).coin.value;

        *balance_ref = balance - amount;

        Coin { value: amount }
    }


    public entry fun initialize(address : &signer, name : string::String, symbol : string::String, decimals : u8, supply : u128)  {

        assert!(signer::address_of(address) == MODULE_OWNER, INVALID_TOKEN_OWNER);

        assert!(!exists<CoinInfo>(MODULE_OWNER), ECOIN_INFO_ALREADY_PUBLISHED);

        move_to(address, CoinInfo{name : name, symbol : symbol, decimals, supply, cap : 0});
    }


    public entry fun register(address : &signer) {
        let account = signer::address_of(address);

        assert!(!exists<CoinStore>(account), THE_ACCOUNT_HAS_BEEN_REGISTERED);

        move_to(address, CoinStore{ coin : Coin{ value : 0 } });
    }


    public entry fun mint(owner : &signer,to : address,amount : u128) acquires CoinStore,CoinInfo{

        assert!(signer::address_of(owner) == MODULE_OWNER, INVALID_TOKEN_OWNER);

        assert!(borrow_global<CoinInfo>(MODULE_OWNER).cap + amount <= borrow_global<CoinInfo>(MODULE_OWNER).supply,EXCEEDING_THE_TOTAL_SUPPLY);

        deposit(to, Coin { value : amount });

        let cap = &mut borrow_global_mut<CoinInfo>(MODULE_OWNER).cap;
        *cap = *cap + amount;
    }



    public entry fun transfer(from : &signer, to : address, amount : u128) acquires CoinStore {

        let coin = withdraw(signer::address_of(from), amount);

        deposit(to, coin);
    }


    public entry fun burn(owner : &signer, amount : u128) acquires CoinStore,CoinInfo {

        assert!(signer::address_of(owner) == MODULE_OWNER, INVALID_TOKEN_OWNER);

        let coin = withdraw(signer::address_of(owner), amount);
        let Coin { value: amount } = coin;

        let cap = &mut borrow_global_mut<CoinInfo>(MODULE_OWNER).cap;
        *cap = *cap - amount;

        let supply = &mut borrow_global_mut<CoinInfo>(MODULE_OWNER).supply;
        *supply = *supply - amount;
    }
}