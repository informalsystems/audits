### IF-INJECTIVE-09
## CLI for launching derivative markets #322

**Status: Resolved**

**Severity**: Low   

**Type**: Implementation & Testing

**Difficulty**: Low

_Surfaced from @informalsystems audit at hash e678a9f8c13090b353c3c1d042a1b0932ac3da38_

CLI support for instant future markets seems to be outdated:

```
injectived tx exchange instant-expiryfuturesmarket-launch inj/atom inj \
  inj atom pricefeed 1623070240 --fees 10inj --from=genesis --chain-id=888 \
  --broadcast-mode=block --yes
Enter keyring passphrase:
Error: exchange fee cannot be nil: <nil>
```
