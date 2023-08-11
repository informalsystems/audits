### IF-INJECTIVE-08
## When a spot market is demolished the outstanding sell orders (and their coins) are frozen #304

**Status: Resolved**

**Severity**: Medium   

**Type**: Protocol, Economics & Implementation

**Difficulty**: Medium

Surfaced from Informal Systems IBC Audit of hash 8b31eedeea8e6b8fea63d656505ada62c788f587

Execute the following commands to create a sell order and demolish the market:

```
injectived tx exchange instant-spot-market-launch atom/inj atom inj \
  --min-price-tick-size=0.000000000000000001 \
  --min-quantity-tick-size=0.000000000000000001 --from=genesis \
  --chain-id=888 --keyring-backend=file --yes
injectived tx exchange deposit 10000.000000000000000000atom \
  --from=inj1cml96vmptgw99syqrrz8az79xer2pcgp0a885r --chain-id=888 \
  --keyring-backend=file --yes
injectived tx exchange create-spot-limit-order sell atom/inj \
  10000.000000000000000000 0.000000000000000001 --from=user1 --chain-id=888 \
  --keyring-backend=file --yes
injectived tx exchange set-spot-market-status \
  0xfbd55f13641acbb6e69d7b59eb335dabe2ecbfea136082ce2eedaba8a0c917a3 \
  Demolished  --title="atom/inj spot market status set" --description="XX" \
  --deposit="10000000000000000000000inj" --from=genesis --chain-id=888 \
  --keyring-backend=file --yes
injectived tx gov vote 1 yes --from=genesis --chain-id=888 \
  --keyring-backend=file --yes
```

Now the market is demolished but `user1` has their coins still frozen:

```
injectived query exchange deposits inj1cml96vmptgw99syqrrz8az79xer2pcgp0a885r 0
deposits:
  atom:
    available_balance: "0.000000000000000000"
    total_balance: "10000.000000000000000000"
```

Moreover, `user1` is not able to cancel the order, in order to retrieve the coins:

```
injectived tx exchange cancel-spot-limit-order "atom/inj" \
0xc6fe5d33615a1c52c08018c47e8bc53646a0e101000000000000000000000000 \
--from=user1  --chain-id=888 --keyring-backend=file --yes
injectived tx exchange cancel-spot-limit-order "atom/inj" \
0xc6fe5d33615a1c52c08018c47e8bc53646a0e101000000000000000000000000 \
--from=user1  --chain-id=888 --keyring-backend=file --yes
Enter keyring passphrase:
{"height":"275",
"txhash":"008037D8E2D3223B05FB36B9EB6FCE3F96CAA36F4419C71A2C7BFFCDE1AC0AF5",
"codespace":"exchange","code":4,"data":"","raw_log":"failed
to execute message; message index: 0: active spot market doesn't exist
0xfbd55f13641acbb6e69d7b59eb335dabe2ecbfea136082ce2eedaba8a0c917a3: spot market
not
found","logs":[],"info":"","gas_wanted":"200000","gas_used":"63531",
"tx":null,"timestamp":""}
```
