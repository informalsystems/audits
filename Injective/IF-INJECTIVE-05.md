### IF-INJECTIVE-05
## Outdated parameters in scripts/propose_spot_market.sh #296

**Status: Resolved**

**Severity**: Low   

**Type**: Implementation & Testing

**Difficulty**: Low

Surfaced from Informal Systems audit of hash 1e4d291

The script https://github.com/InjectiveLabs/injective-core/blob/dev/scripts/propose_spot_market.sh fails to launch a spot market:

```sh
./scripts/propose_spot_market.sh 
Error: accepts 3 arg(s), received 5
Usage:
  injectived tx exchange spot-market-launch [ticker] [base_denom] 
  [quote_denom] [flags]
...
```

I believe that the following line:

https://github.com/InjectiveLabs/injective-core/blob/1e4d2914b3ae616b98b05fb70eb487550fc99ed7/scripts/propose_spot_market.sh#L13

should be replaced with:

```sh
yes $PASSPHRASE | injectived tx exchange spot-market-launch "$Ticker" \
"$BaseDenom" "$QuoteDenom"  --min-price-tick-size="$MaxPriceScaleDecimals" \
--min-quantity-tick-size="$MaxQuantityScaleDecimals" --title="$Title" \
--description="$Description" --deposit="100000000000inj" --from=genesis \
--chain-id=888 --keyring-backend=file --yes
```
