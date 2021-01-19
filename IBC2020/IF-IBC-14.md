
### IF-IBC-14
## ICS20 - Panic on receiving multi-chain denominations

**Severity**: High  
**Type**: Implementation bug  
**Difficulty**: Low     
**Involved artifacts**: 
[applications/transfer/keeper/relay.go:OnRecvPacket()](https://github.com/cosmos/cosmos-sdk/blob/6de0e18f0aed9685db75177722415701a2bb65c7/x/ibc/applications/transfer/keeper/relay.go#L221),
[model-based tests for token transfer](https://github.com/cosmos/cosmos-sdk/blob/6de0e18f0aed9685db75177722415701a2bb65c7/x/ibc/applications/transfer/keeper/mbt_relay_test.go#L291)   
**Issues / PRs**: [Cosmos-SDK #8120](https://github.com/cosmos/cosmos-sdk/issues/8120), [Cosmos-SDK #8119](https://github.com/cosmos/cosmos-sdk/pull/8119)

### Description

In the following code fragment of [applications/transfer/keeper/relay.go:OnRecvPacket()](https://github.com/cosmos/cosmos-sdk/blob/6de0e18f0aed9685db75177722415701a2bb65c7/x/ibc/applications/transfer/keeper/relay.go#L221), it is assumed that the denomination trace can contain at most two components, i.e. the unprefixed denomination is a native token:



```go
if types.ReceiverChainIsSource(packet.GetSourcePort(), 
     packet.GetSourceChannel(), data.Denom) {
	// sender chain is not the source, unescrow tokens
	// remove prefix added by sender chain
	voucherPrefix := types.GetDenomPrefix(packet.GetSourcePort(), 
	  packet.GetSourceChannel())
	unprefixedDenom := data.Denom[len(voucherPrefix):]
	token := sdk.NewCoin(unprefixedDenom, sdk.NewIntFromUint64(data.Amount))
```

This assumption was valid for all Cosmos-SDK tests for token transfer present at the time of our audit, in particular for the quite extensive [handler_test.go](https://github.com/cosmos/cosmos-sdk/blob/6de0e18f0aed9685db75177722415701a2bb65c7/x/ibc/applications/transfer/handler_test.go).

Nevertheless, the following simple TLA+ test, that was executed as part of our model-based testing efforts for token transfer module, generated an execution with a token transfer crossing 3 chains:

```tla
TestUnescrowTokens ==
  \E s \in DOMAIN history :
     /\ IsSource(history[s].packet)
     /\ history[s].handler = "OnRecvPacket"
     /\ history[s].error = FALSE
```

This 3-chain token transfer resulted in the receiving denomination being a non-native token, and led to the panic in the implementation; see details in the issue [Cosmos-SDK #8120](https://github.com/cosmos/cosmos-sdk/issues/8120).

### Problem Scenarios

Consider the following scenario, involving three chains: A, B, and C. Transfer channel from A to B has as id `channel-0` for both channel ends, and transfer channel from B to C has as ids for channel ends `channel-1` and `channel-0` respectively. We are interested in the token transfer module of chain B, and consider all steps relative to chain B. The following steps are generated from the TLA+ test above:

0. Initialization: bank of B is empty. 
1. Receive 5 atoms from chain A to account a3
    * transferred denomination: `atom`
    * expected bank state: 
      * `<a3, transfer/channel-0/atom> = 5`
2. Send 3 atoms from account a3 on chain B to chain C (funds are moved to the escrow account)
    * transferred denomination: `transfer/channel-0/atom`
   * expected bank state:
     * `<a3, transfer/channel-0/atom> = 2`
     * `<transfer/channel-1, transfer/channel-0/atom> = 3`
3. Receive 1 atom from chain C to account a1 on chain B (funds are moved from the escrow account)
    * transferred denomination: `transfer/channel-0/transfer/channel-0/atom`
    * expected bank state:
      * `<a3, transfer/channel-0/atom> = 2`
      * `<transfer/channel-1, transfer/channel-0/atom> = 2`
      * `<a1, transfer/channel-0/atom> = 1`

As can be seen in the step 3 above, the unprefixed denomination is not native, which leads to the implementation panic.

### Recommendation

The problem has been promptly fixed by the developers in this PR: [Cosmos-SDK #8119](https://github.com/cosmos/cosmos-sdk/pull/8119). The fix is simple, 
and consists of hashing of the received denomination.

The developers have also promptly updated the hand-written test in order to test the 3-chain scenario above, 
see the [file changes](https://github.com/cosmos/cosmos-sdk/pull/8119/files). It is worth comparing the length of 
the modifications to the hand-written test that were necessary to cover the 3-chain scenario with the conciseness of 
the TLA+ test above.

While our model-based tests for the token transfer module, including the TLA+ test above, have been successfully 
merged into Cosmos-SDK (see the PR [Cosmos-SDK #8145](https://github.com/cosmos/cosmos-sdk/pull/8145)), only a very 
limited number of tests are contained there. We recommend the Cosmos-SDK developers to master the model-based testing 
methodology (see IF-IBC-13 for a short description), and to extend their test suite with more model-based tests. 
This should help both to reduce the testing efforts from the developers, and to increase the coverage of complicated scenarios.  