### IF-INJECTIVE-03
## Missing validation tests in MsgInstantSpotMarketLaunch, results in division by zero #291

**Status: Resolved**

**Severity**: Low   

**Type**: Implementation & Testing

**Difficulty**: Low

Surfaced from Informal Systems audit of hash 043a2402e59a985400c676dc6d4b6fa1ca85567b

It is possible to launch a market with incorrect parameters that results in a transaction panic later. Consider the following sequence of commands in the standard setup, as done with `./setup.sh`:

```
injectived tx exchange instant-spot-market-launch INJ/INJ inj inj \
  --from=genesis --chain-id=888 --keyring-backend=file
injectived tx exchange deposit 10000000inj --chain-id 888 \
  --from inj1cml96vmptgw99syqrrz8az79xer2pcgp0a885r
injectived tx exchange create-spot-limit-order buy INJ/INJ 10 10 \
  --from=user1 --chain-id=888 --keyring-backend=file
```

This leads to a transaction panic:

```json
{"height":"2318",[...] to execute message; message index: 0: division by zero:
panic","logs":[],"info":"","gas_wanted":"200000","gas_used":"64317",
"tx":null,"timestamp":""}
```

The reason is that the market is launched with `min_price_tick_size = 0`:

```
injectived query exchange spot-markets
markets:
- base_denom: inj
  maker_fee_rate: "0.001000000000000000"
  market_id: 0x3b78a9b8efc920e7021cc30cb3c821df189585cc3eaa35d73ec8853a1780961d
  min_price_tick_size: "0.000000000000000000"
  min_quantity_tick_size: "0.000000000000000000"
  quote_denom: inj
  relayer_fee_share_rate: "1.000000000000000000"
  status: Active
  taker_fee_rate: "0.002000000000000000"
  ticker: INJ/INJ
```
