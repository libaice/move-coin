### move contract Demo -- Token

1. aptos init  generate .aptos file (contains rpc and prikey)
2. (if need faucet )    aptos account fund-with-faucet --account [your address]
3. compile contracts `aptos move compile --named-addresses NBCOIN=default `
4. publish (deploy contracts )  `aptos move publish --named-addresses NBCOIN=default`
    now can see my publish tx in [aptos testnet explorer](https://explorer.aptoslabs.com/txn/0x04304a79b862f1938550c8b517f5e1ed2aadc7797ede2a5e07a7905deb11cb24?network=testnet)

5. Our Coin should be initilized when we has deployed the Token 
   run `aptos move run --function-id 'default::TestCoin::initialize' --args 'string::BAICECOIN' 'string::BCT' u8:8 u128:100000000` 
    

    in this command we define all params in the initialize function [founction id, args(type::param)]
    this function use [move_to](https://move-book.com/resources/resource-by-example/storing-new-resource.html)

    > function move_to which takes signer as a first argument and Collection as second
    > put a resource under your account *Once*
    > Second attempt to create existing resource will fail with error.

6. now I need to register this token to my account .
    ` aptos move run --function-id 'default::TestCoin::register' `

7. mint some token for me
    `aptos move run --function-id 'default::TestCoin::mint' --args address:default u128:1000000`
    I can get all my tokens in the [aptos rpc url](https://fullnode.testnet.aptoslabs.com/v1/accounts/0x85c30a87fb365137ac507ed2daa316a21f8b1f64bcd28f0adea60f4f8a1e1cc7/resource/0x85c30a87fb365137ac507ed2daa316a21f8b1f64bcd28f0adea60f4f8a1e1cc7::TestCoin::CoinInfo) in my account resource 

8. I can make an another account (import from prikey in testnet) used as a receiver token address 
    profile define another wallet name , my first is default
    `aptos init --profile a2  ` 

9. register another account 
   `aptos move run --profile a2 --function-id 'default::TestCoin::register'`

10. now test transfer token from my resource to a2's resource
    `aptos move run --function-id 'default::TestCoin::transfer' --args address:a2 u128:33333`

    now we see : 
    my default coin value has decrease 33333

    https://fullnode.testnet.aptoslabs.com/v1/accounts/0x85c30a87fb365137ac507ed2daa316a21f8b1f64bcd28f0adea60f4f8a1e1cc7/resource/0x85c30a87fb365137ac507ed2daa316a21f8b1f64bcd28f0adea60f4f8a1e1cc7::TestCoin::CoinStore

    and my another wallet coin value has increased 33333
    https://fullnode.testnet.aptoslabs.com/v1/accounts/0xd7d1b12297217d5ded851c03c28ed98085997c058402dc27045fec49efbf1270/resource/0x85c30a87fb365137ac507ed2daa316a21f8b1f64bcd28f0adea60f4f8a1e1cc7::TestCoin::CoinStore

11. Test burn my token from my resources
    `aptos move run --function-id 'default::TestCoin::burn' --args  u128:667 `
    and then the coinStore value decrease 667 