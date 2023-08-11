
### IF-IBC-12
## Non-atomicity of operations

**Severity**: Informative   
**Type**: Bad software practice / lack of documentation   
**Difficulty**: Easy     
**Involved artifacts**: [ICS 20 Specification](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-020-fungible-token-transfer), 
[bank/spec](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/bank/spec),
[ibc/types/coin.go](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/types/coin.go#L136),
[ibc/applications/transfer](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/).   
**Issue**: [Cosmos SDK #8030](https://github.com/cosmos/cosmos-sdk/issues/8030)

### Description

In multiple places throughout the Cosmos-SDK, functions contain several sub-calls that may fail due to various reasons. 
At the same time, the sub-calls update the shared state, and the functions do not backtrack the state changes 
done by the first sub-calls if one of the subsequent sub-calls fails.  

Consider this example of [SubtractCoins()](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/bank/keeper/send.go#L179):  

```go
for _, coin := range amt {
    balance := k.GetBalance(ctx, addr, coin.Denom)
    locked := sdk.NewCoin(coin.Denom, lockedCoins.AmountOf(coin.Denom))
    spendable := balance.Sub(locked)
    _, hasNeg := sdk.Coins{spendable}.SafeSub(sdk.Coins{coin})
    if hasNeg {
        return sdkerrors.Wrapf(sdkerrors.ErrInsufficientFunds, "%s is smaller than %s", spendable, coin)
    }
    newBalance := balance.Sub(coin)
    err := k.SetBalance(ctx, addr, newBalance)
    if err != nil {
        return err
    }
}
```

The function iterates over the set of coins and for each coin checks whether enough coins are available for the current 
denomination. The balance is updated for each coin as the loop progresses. Consider the scenario where the balance for 
the first coin is updated successfully, but for the second coin setting of the balance fails because of the negative 
amount of coins. The function returns the error, but the balance for the first coin remains updated in the shared state.

**This violates one of the most basic assumptions of function atomicity**, namely that either

  1. the function updates the state and succeeds, or   
  2. the function returns an error, but the shared state is unmodified.

We have found multiple occasions of such non-atomic functions; here are some, besides the example above:

Bank:

* [AddCoins](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/bank/keeper/send.go#L210) similar issue with the difference it panics when overflow happens for some denomination. 
*  [SendCoins](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/bank/keeper/send.go#L140) first subtracts from the sender account and then adds to the receiver. If subtract is successful and add fails the state is changed. 
* [DelegateCoins](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/bank/keeper/keeper.go#L85): delegation is processed denomination by denomination: the insufficient funds is check inside the loop allowing state updates even when an error is reached. 
* [UndelegateCoins](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/bank/keeper/keeper.go#L129) similar scenario. 
* [BurnCoins](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/bank/keeper/keeper.go#L352) and [MintCoins](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/bank/keeper/keeper.go#L323) use SubtractCoins and AddCoins. 

ICS20:

* [OnRecvPacket](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/keeper/relay.go#L185): first [minting](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/keeper/relay.go#L274) then [moving into the account](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/keeper/relay.go#L281). Each step modifies the bank state. Each step potentially reaches errors. Therefore it is not an atomic write to the bank as given in the [spec](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-020-fungible-token-transfer). 
* [SendTransfer](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/keeper/relay.go#L49): similar to `OnRecvPacket`, first [SendCoinsFromAccountToModule()](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/keeper/relay.go#L128) is called, that modifies the state, and after that, if [BurnCoins()](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/keeper/relay.go#L134) fails, the error is returned, but the state is left modified.


The problem is that **all above functions have implicit assumption on the behavior of the caller**. This implicit 
assumption is that whenever any such function returns an error, the only correct behavior is to propagate this error 
up the stack.

While this assumption seems indeed to be satisfied by the present Cosmos SDK codebase (with one exception, see the 
problem scenario below), it is not documented anywhere in the Cosmos SDK developer documentation. There are only hints 
to this in the form similar to this paragraph in the [Cosmos SDK handler documentation](https://docs.cosmos.network/v0.39/building-modules/handler.html#handler-type):

> The Context contains all the necessary information needed to process the msg, as well as a cache-wrapped copy of the latest state. If the msg is succesfully processed, the modified version of the temporary state contained in the ctx will be written to the main state.

Such hints do not constitute enough developer guidance to avoid introducing severe bugs, especially for Cosmos SDK newcomers.

### Problem Scenarios

We have found one particular place where this non-atomicity has almost led to the real bug. Namely, in 
ICS20 [OnRecvPacket](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/keeper/relay.go#L273-L285) 
we have two consecutive operations, minting and sending.

```go
// mint new tokens if the source of the transfer is the same chain
if err := k.bankKeeper.MintCoins(
    ctx, types.ModuleName, sdk.NewCoins(voucher),
); err != nil {
    return err
}


// send to receiver
if err := k.bankKeeper.SendCoinsFromModuleToAccount(
    ctx, types.ModuleName, receiver, sdk.NewCoins(voucher),
); err != nil {
    return err
}
```

If the minting succeeds, but the sending fails, the function returns an error, while the funds are moved to the module account.

This is how this function is called in [applications/transfer/module.go](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/module.go#L315-L318):

```go
err := am.keeper.OnRecvPacket(ctx, packet, data)
if err != nil {
    acknowledgement = channeltypes.NewErrorAcknowledgement(err.Error())
}
```

We see that the error is turned into a negative acknowledgement. **If sending of the coins above was to fail with an error, 
then the negative acknowledgement would be sent, but also the funds would be silently moved to the module account under 
the hood.** We have carefully examined the code of `SendCoinsFromModuleToAccount`, and found out that its current implementation can only panic, e.g. when the receiver account overflows. But if there was a possibility for it to return an error this scenario would constitute a real problem. Please note that these two functions are probably written by two different developers, and it would be perfectly legitimate for `SendCoinsFromModuleToAccount` to return an error -- this is how close it comes to being a real bug. Please see also the finding [IF-IBC-01](../spec-findings/IF-IBC-01.md) for more details on this issue.

### Recommendation

* **Short term**: properly **explain in the developer documentation the implicit assumption** of propagating all returned 
  errors up the stack , as well as in the inline documentation for all functions exhibiting non-atomic behavior.
* **Long term**: one of the following needs to be done:
  * either **make the SDK functions atomic** as described above;
  * or **introduce a separate explicit step** for handlers, say `CommitState`, that the handler will need to call to 
    write state changes to the store.
    
