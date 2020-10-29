# ICS 20

## Findings Opened As Issues:

- Discrepencies between spec and code and other improvements to the code: https://github.com/cosmos/cosmos-sdk/issues/7736
- GetEscrowAddress pre-image could be a real public key: https://github.com/cosmos/cosmos-sdk/issues/7737

## Spec does not match code

- [error
  handling](https://github.com/cosmos/cosmos-sdk/blob/82f15f306e8a6a2e9ae3e122c348b579c43a3d92/x/ibc/applications/transfer/keeper/relay.go#L225)
  less specific than `FungibleTokenPacketAcknowledgement`
  - EB: Josef can you clarify? TransferCoins in the onRecvPacket spec does return an error, just like SendCoins in the code - a malicious sender chain could try to withdraw more coins than were ever escrowed. Maybe this should be considered a more severe error and worth closing the channel over?

- the logic of
  [genesis.go](https://github.com/cosmos/cosmos-sdk/blob/82f15f306e8a6a2e9ae3e122c348b579c43a3d92/x/ibc/applications/transfer/keeper/genesis.go)
  is not disussed in the spec.
  - EB: this is outside scope of the ICS and will be the case for every module. Should be defined in the SDK IBC spec though.


  
## Questions

- check
  [comment](https://github.com/cosmos/cosmos-sdk/blob/82f15f306e8a6a2e9ae3e122c348b579c43a3d92/x/ibc/applications/transfer/keeper/relay.go#L137)
  ... also there is a typo
  
- how does
  [that](https://github.com/cosmos/cosmos-sdk/blob/82f15f306e8a6a2e9ae3e122c348b579c43a3d92/x/bank/keeper/send.go#L140) work?
  
- what is the motivation of [that](https://github.com/cosmos/cosmos-sdk/blob/82f15f306e8a6a2e9ae3e122c348b579c43a3d92/x/bank/keeper/send.go#L164)?
  

- what is
 
  
## Implementation Spec

- not very complete. not sure what is the state, purpose. would be a
  good place to link ICS spec to code (what do I find where), and
  discuss discrepancies.

- this
  [spec](https://github.com/cosmos/cosmos-sdk/blob/82f15f306e8a6a2e9ae3e122c348b579c43a3d92/x/ibc/applications/transfer/spec/04_messages.md)
  is the closest to describing what is happinging in transfer
  
  

  
# Raw Comments on ICS 20

## Generic review (verification) checks

- Ocaps (object capabilities)
- determinism
- messages out-of-order
    * questions: ordered channels. transactions within same block
- type casts, e.g. `FungibleTokenPacketData data = packet.data`
- string operations
- implicit assumptions about well-formed packets 

## comments on ICS 20 

- refundTokens: denomination -> data.denomination; also I don’t understand the branching. What if neither was the souce chain? Or is multihop ignored?
- ModuleState does not match implementation
- what is the role of these comments
    * // port has already been validated
    * // accept channel confirmations, port has already been validated, version has already been validated
- this might be a typo:
```
acknowledgement: bytes) {
  // if the transfer failed, refund the tokens
  if (!ack.success)
```
- onRecvPacket: how do I check that the packet comes from the right
chain. If it is called with a packet
{packet.sourcePort}/{packet.sourceChannel} are OK 
    * -> invariant of IBC incoming packets. 
    * If the packet comes from a lightclient attack the invariant about not printing money needs to be ensured by bank.TransferCoins
(comments  `// receiver is source chain: unescrow tokens`

- `source: boolean` in createOutgoingPacket??


### Input?

- createOutgoingPacket must be called by a transaction handler in the module which performs appropriate signature checks, specific to the account owner on the host state machine. -> does this describe an input? Do we need to check it? It seems it doesn’t care and leaves all error handling to the bank and to handler.sendPacket

- prefix = "{sourcePort}/{sourceChannel}"  
  `// we are the source if the denomination is not prefixed`
  
- The expected syntax of the denomination string is not explicit.
- How does a packet look like that will result in a token transfer?
- Is there a relationship between receiver and destPort and destChannel?
- There are some implicit invariants on FungibleTokenPacketData, and the packet’s {packet.sourcePort}/{packet.sourceChannel} and denomination, sender, receiver
- Does this define the grammar of denomination? Does this result in unambiguous strings?
prefix = "{packet.destPort}/{packet.destChannel}"
    prefixedDenomination = prefix + data.denomination
- There is a comment “and the denomination will be "{portOnD}/{channelOnD}/{portOnB}/{channelOnB}/denom"



## external relationships of ICS 20

- routingModule.bindPort
- claimCapability("port", capability)
- abortTransactionUnless
- what is the assumption (precondition) about an incoming packet.
- newAddress()
- handler.sendPacket(Packet{timeoutHeight, timeoutTimestamp, destPort, destChannel, sourcePort, sourceChannel, data}, getCapability("port"))
    * no error code
- bank.TransferCoins(escrowAccount, data.receiver, data.denomination.slice(len(prefix)), data.amount)
- bank.MintCoins(data.receiver, prefixedDenomination, data.amount)


## ICS 26

- `capability = handler.bindPort(id)`; bindport not mentioned in ICS 25


