
### IF-IBC-06
## ICS20 - Specification allows token lost issue in the crossing hellos scenario 

**Severity**: High  
**Type**: Specification error  
**Difficulty**: easy     
**Involved artifacts**: [ICS 20](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-020-fungible-token-transfer), [applications/transfer/module.go](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/applications/transfer/module.go)

### Description

The ICS20 specification uses undefined `newAddress()` in [onChanOpenInit](https://github.com/cosmos/ics/tree/eb31a56467a48cd7eb4c2232705ad0fc632f9a19/spec/ics-020-fungible-token-transfer#routing-module-callbacks) and 
`onChanOpenTry` to create an escrow address and stores it in a map under the `channel id` as a key. In the case of 
crossing-hello scenario, different escrow accounts are created both in `onChanOpenInit` and `onChanOpenTry`, with
latter overwriting the former. This can lead to the token lost issue if `createOutgoingPacket` is called in 
between.

### Problem Scenarios

Imagine the following scenario:

- on chain A `onChanOpenInit` is called which leads to the creation of the escrow address `E1`
that is stored in `channelEscrowAddresses` under `channelIdentifier` as a key 

- on chain A, `createOutgoingPacket` is called, and it moves tokens to the escrow address `E1`
 
- on chain A, `onChanOpenTry` is called that creates a new escrow 
address `E2` that replaces `E1` in the `channelEscrowAddresses` map under `channelIdentifier` as a key.

- on chain A, `onRecvPacket` is called to withdraw tokens that are escrowed in `E1` with `createOutgoingPacket`.
It will fail as there are no tokens in the escrow account `channelEscrowAddresses[channelIdentifier]` as it points to `E2`, 
while tokens are in `E1`.


### Recommendation

In `onChanOpenTry`, the escrow account should be created only if it does not exist, i.e.,
a check should be added to create an escrow account only if `channelEscrowAddresses[channelIdentifier]` 
does not exist.

Note that the in the SDK implementation of the ICS20, code uses a deterministic function 
to create an escrow account that receives two parameters `portId` and `channelId`. Therefore,
this implementation does not suffer from the problem mentioned here as the implementation differ 
from the specification, i.e., only one escrow account is created in the mentioned scenario.

