
### IF-IBC-11
## ICS03/04 - Crossing hellos with fixed identifier are not live

**Severity**: Medium  
**Type**: protocol/implementation bug   
**Difficulty**: medium     
**Involved artifacts**: 
[ICS 03 specification](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-003-connection-semantics), 
[ICS 04 specification](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-004-channel-and-packet-semantics), 
[ibc/core/03-connection/keeper/handshake.go](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/core/03-connection/keeper/handshake.go#L117)
[ibc/core/04-channel/keeper/handshake.go](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/core/04-channel/keeper/handshake.go#L118)


### Description

When two chains want to open a connection (channel), they may 
both initialize their connection (channel) ends by calling 
`connOpenInit` (`chanOpenInit`), before a correct relayer creates
a `ConnOpenTry` (`ChanOpenTry`) datagram for either chain.
In this scenario, in both the code and specification 
of the connection (channel) handshake protocols, 
the two chains may initialize their connection (channel) 
ends with parameters that do not match.
This causes both chains to abort when calling `connOpenTry` (`chanOpenTry`).
Thus, their already initialized connection (channel) ends 
remain in state `INIT` forever, 
which violates the following liveness property:

> If a connection (channel) end is initialized on a chain, 
then eventually both the connection (channel) end,
stored on the chain, and the connection (channel) end, stored 
at its counterparty, are open.

In the following, we discuss this issue by focusing on the 
specification of the connection handshake; the discussion for 
the channel handshake, as well as the implementations, is analogous.
We show a scenario where two chains want to open a connection but 
have mismatched client identifiers.
Observe that this issue may arise not only in cases where client identifiers are 
mismatched, but also when connection, channel, port identifiers, versions, prefixes, 
or orderings coming from a `ConnOpenTry` (`ChanOpenTry`) datagram
do not match the values stored in the existing connection (channel) end on the receiving chain.

### Problem Scenarios

When two chains want to open a connection, they may
both initialize their connection ends by calling `connOpenInit`, 
which may result in a chain assigning values to the 
fields in its connection end that do not match the 
values of the respective fields in the counterparty connection end
(even if the connection and counterparty connection identifiers match).
In this scenario, once a correct relayer creates a `ConnOpenTry` datagram for 
each chain, the call to `connOpenTry` fails on at least one of the chains.
This implies that the connection handshake does not progress, 
and the above liveness property is violated.

In more detail, consider the scenario where two chains, 
`"ChainA"` and `"ChainB"`, want to open a connection.
Suppose that `"ChainA"` has two clients for `"ChainB"`, identified by 
the client identifiers `"clientB1"` and `"clientB2"`. 
Suppose that `"ChainB"` has a single client for `"ChainA"`, identified by 
the client identifier `"clientA1"`. 
To open a connection, both chains execute the following steps: 

1. `"ChainA"` calls `connOpenInit` and initializes its connection end with the 
following values: 
    - connection identifier: `"connAtoB"`, 
    - counterparty connection identifier: `"connBtoA"`,
    - client identifier: `"clientB1"`,
    - counterparty client identifier: `"clientA1"`,
1. `"ChainB"` calls `connOpenInit` and initializes its connection end with 
the following values: 
    - connection identifier: `"connBtoA"`, 
    - counterparty connection identifier: `"connAtoB"`,
    - client identifier: `"clientA1"`,
    - counterparty client identifier: `"clientB2"`,
1. a correct relayer creates a `ConnOpenTry` datagram for `"ChainB"` by scanning 
`"ChainA"`'s state, where the field `clientIdentifier` is set to `"clientA1"`, 
and the field `counterpartyClientIdentifer` is set to `"clientB1"`.
1. a correct relayer creates a `ConnOpenTry` datagram for `"ChainA"` by scanning 
`"ChainB"`'s state, where the field `clientIdentifier` is set to `"clientB2"`, 
and the field `counterpartyClientIdentifer` is set to `"clientA1"`.
1. `"ChainB"` receives the `ConnOpenTry` datagram and calls `connOpenTry`. 
A connection end on `"ChainB"` is already initialized, and the connection and 
counterparty connection identifiers match those from the 
`ConnOpenTry` datagram.
However, the existing connection end has `counterpartyClientIdentifer` set to 
`"clientB2"`, which does not match the identifer 
`"clientB1"`, coming from the field `counterpartyClientIdentifer` from the
`ConnOpenTry` datagram. 
1. `"ChainA"` receives the `ConnOpenTry` datagram and calls `connOpenTry`. 
A connection end on `"ChainA"` is already initialized, and the connection and 
counterparty connection identifiers match those from the 
`ConnOpenTry` datagram.
However, the existing connection end has `clientIdentifer` set to 
`"clientB1"`, which does not match the identifer 
`"clientB2"`, coming from the field `counterpartyClientIdentifer` from the
`ConnOpenTry` datagram. 

The call to `connOpenTry` thus fails here, on both sides:

```go
abortTransactionUnless(
      (previous === null) ||
      (previous.state === INIT &&
        previous.counterpartyConnectionIdentifier === 
          counterpartyConnectionIdentifier &&
        previous.counterpartyPrefix === counterpartyPrefix &&
        previous.clientIdentifier === clientIdentifier &&
        previous.counterpartyClientIdentifier === 
          counterpartyClientIdentifier))
```
where `previous` is the initialized connection end.

### Recommendation

Add a mechanism in both the specification, and the implementation 
to deal with mismatched parameters. 

#### Note
At the time of writing this report, the following issues 
were opened to address this problem 
in the case when the connection (channel) identifiers do not match:
[Cosmos-ICS #491](https://github.com/cosmos/ics/issues/491) and [Cosmos-SDK #7870](https://github.com/cosmos/cosmos-sdk/issues/7870).
