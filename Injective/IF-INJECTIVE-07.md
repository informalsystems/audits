### IF-INJECTIVE-07
## Changing the status of a spot market to Demolished introduces a market copy #302

**Status: Resolved**

**Severity**: Medium   

**Type**: Protocol, Economics & Implementation

**Difficulty**: Medium

Surfaced from Informal Systems IBC Audit of hash e39a091

Changing the market status to Demolished introduces a market copy

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

injectived query exchange spot-markets
markets:
- base_denom: atom
  maker_fee_rate: "0.001000000000000000"
  market_id: 0xfbd55f13641acbb6e69d7b59eb335dabe2ecbfea136082ce2eedaba8a0c917a3
  min_price_tick_size: "0.000000000000000001"
  min_quantity_tick_size: "0.000000000000000001"
  quote_denom: inj
  relayer_fee_share_rate: "1.000000000000000000"
  status: Demolished
  taker_fee_rate: "0.002000000000000000"
  ticker: atom/inj
- base_denom: atom
  maker_fee_rate: "0.001000000000000000"
  market_id: 0xfbd55f13641acbb6e69d7b59eb335dabe2ecbfea136082ce2eedaba8a0c917a3
  min_price_tick_size: "0.000000000000000001"
  min_quantity_tick_size: "0.000000000000000001"
  quote_denom: inj
  relayer_fee_share_rate: "1.000000000000000000"
  status: Active
  taker_fee_rate: "0.002000000000000000"
  ticker: atom/inj
```
