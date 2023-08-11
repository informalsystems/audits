### IF-INJECTIVE-06
## Incorrect parsing of arguments for injectived tx exchange create-spot-market-order #299

**Status: Resolved**

**Severity**: Low   

**Type**: Implementation & Testing

**Difficulty**: Low

Surfaced from Informal Systems audit of hash 0189db186636991fd9076ee741d67ff05ae4c2c1

This is just a bug in functionality. The code below is using `args[1]` and `args[2]` for the quantity and price, whereas it should use `args[2]` and `args[3]`.

https://github.com/InjectiveLabs/injective-core/blob/0189db186636991fd9076ee741d67ff05ae4c2c1/injective-chain/modules/exchange/client/cli/tx.go#L263-L279

