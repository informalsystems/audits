
### IF-IBC-13
## ICS20 - Model and Model-based Tests for Token Transfer

**Severity**: Informative   
**Type**: Set of new artifacts to facilitate rigorous testing    
**Involved original artifacts**: [ICS 20 Specification](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-020-fungible-token-transfer),
[ibc/applications/transfer](https://github.com/cosmos/cosmos-sdk/blob/cbbad6b57d17aee969cf35a6e45c5251d798ee5c/x/ibc/applications/transfer/).   
**Issues / PRs**: [Cosmos SDK #8120](https://github.com/cosmos/cosmos-sdk/issues/8120), [Cosmos SDK #8145](https://github.com/cosmos/cosmos-sdk/pull/8145)

### Description

The set of developed artifacts covers the efforts of creating a preliminary model and a set of model-based tests for
ICS-20 token transfer. While this work is of an exploratory nature, it already helped to catch the bug in the Go implementation;
see [Cosmos SDK #8120](https://github.com/cosmos/cosmos-sdk/issues/8120).

Considering ICS-20 Token Transfer a critical component of the IBC infrastructure, we have invested some time into
formally modeling and verifying it using TLA+ and Apalache model checker, and creating the set of tests based on this model.
Below we describe the main components of the developed artifact.

### The TLA+ model of ICS-20 Token Transfer relay functions

The model in its entirety can be found
[here](https://github.com/cosmos/cosmos-sdk/blob/cbbad6b57d17aee969cf35a6e45c5251d798ee5c/x/ibc/applications/transfer/keeper/relay_model/). Our TLA+ model is based both on the specification as well as on the implementation. The main file of the TLA+ model is [relay.tla](https://github.com/cosmos/cosmos-sdk/blob/cbbad6b57d17aee969cf35a6e45c5251d798ee5c/x/ibc/applications/transfer/keeper/relay_model/relay.tla). For all main relay functions (`SendTransfer`, `OnRecvPacket`, `OnTimeoutPacket`, `OnAcknowledgementPacket`) it contains pre- and post-conditions of those functions. Based on those, it is possible to generate execution sequences of abstract "calls" to this functions, either successful or not, and to record those executions in the execution history. The history is later used to construct tests for the implementation in Go.

As an example we provide here a TLA+ precondition for the `OnRecvPacket` function:

```tla
OnRecvPacketPre(packet) ==
  LET data == packet.data
      trace == data.denomTrace
      denom == GetDenom(trace)
      amount == data.amount
  IN
  /\ WellFormedPacket(packet)
  /\ IsValidRecvChannel(packet)
  /\ IsValidDenomTrace(trace)
  /\ amount > 0
     \* if there is no receiver account, it is created by the bank
  /\ data.receiver /= NullId
  /\ IsSource(packet) =>
       LET escrow == GetDestEscrowAccount(packet) IN
       LET denomTrace == ReduceDenomTrace(trace) IN
           /\ <<escrow, denomTrace>> \in DOMAIN bank
           /\ bank[escrow, denomTrace] >= amount
```

### Model-based tests for relay functions

The above TLA+ model is complemented with a set of model-based tests, that can be found in [relay_tests.tla](https://github.com/cosmos/cosmos-sdk/blob/cbbad6b57d17aee969cf35a6e45c5251d798ee5c/x/ibc/applications/transfer/keeper/relay_model/relay_tests.tla). Model-based tests are simple TLA+ assertions that describe desired executions. Here is a simple example:

```tla
TestUnescrowTokens ==
  \E s \in DOMAIN history :
     /\ history[s].handler = "OnRecvPacket"
     /\ history[s].error = FALSE
     /\ IsSource(history[s].packet)
```

This test requires an existence of a computation history state such that:
* `OnRecvPacket` is called in this state;
* the call is successful;
* The received packet originated from the receiving chain.

When the model contains three chains, A, B, C, such that A is connected to B, and B is connected to C, this combination of conditions forces the model checker to generate an example execution consisting of three steps (we are on chain B):
1. Some tokens are received from A to B (`OnRecvPacket` on chain B);
2. Some of the received tokens are sent from B to C (`SendTransfer` on chain B);
3. Some of the previosly sent tokens are received back from C to B, and unescrowed there. (`OnRecvPacket` on chain B).

The model together with the test is executed by our model checker [Apalache](https://github.com/informalsystems/apalache). The example execution is recorded by the model checker as a so-called _counterexample_.


### Transformation specification

As a counterexample produced by the model checker contains an arbitrary syntax tree of TLA+, this needs to be translated into a machine-readable form, that can be parsed by the test driver. This translation is performed by another software component, [Jsonatr (JSON Arrifact Translator)](https://github.com/informalsystems/jsonatr). The transformation is described by a [transformation specification](https://github.com/cosmos/cosmos-sdk/blob/cbbad6b57d17aee969cf35a6e45c5251d798ee5c/x/ibc/applications/transfer/keeper/relay_model/apalache-to-relay-test2.json).

### Model-based test driver

Finally, the transformed model execution is executed by the test driver [mbt_relay_test.go](https://github.com/cosmos/cosmos-sdk/blob/cbbad6b57d17aee969cf35a6e45c5251d798ee5c/x/ibc/applications/transfer/keeper/mbt_relay_test.go), which is a simple Go component, integrated into the IBC testing framework. The test driver does the following:
1. Sets up the test environment, consisting of the necessary number of chains and their connections;
2. Deserializes the transformed model execution;
3. For each step of the execution, calls the corresponding relay function of the token transfer module;
4. Checks the returned result and the changes in the chain bank module are as expected by the model execution.


### Recommendation

Our model-based tests for the token transfer module have been successfully merged into Cosmos-SDK (see the PR [Cosmos-SDK #8145](https://github.com/cosmos/cosmos-sdk/pull/8145)), and already helped to catch a real implementation bug in a complicated 3-chain scenario; see IF-IBC-14.

At the same time, only a very limited number of tests are contained there. We recommend the Cosmos-SDK developers to master the model-based testing methodology, and to extend their test suite with more model-based tests. This should help both to reduce the testing efforts from the developers, and to increase the coverage of complicated scenarios.
