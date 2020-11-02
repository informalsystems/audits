# ICS 04

    
## ICS04 invariants

ICS04 allows modules on different chains to exchange packets in a reliable and secure way. 
If channel is ordered, then ordering of packet sent is respected on the delivery.

Modules on different chains need to establish initial trust in the form of trusted header state.
More precisely, given a module A on chainA and a module B on chainB, the module A needs to install 
a trusted header of the chainB that will be used as a source of trusted for the module B on chainB,
and that is used to verify state transitions on the chainB. The same should be true in the opposite
direction.

   
 

Questions:

- What is exactly meant with "delivered in order sent"? As packets has associated sequence numbers 
we don't need to strictly send them in order (generate packets), we just need to deliver them in 
the order of sequence numbers?


## Findings

- in sendPacket, capability appears out of nowhere. It should probably be passed as a parameter. 
- in sendPacket, these two checks seems not necessary:
abortTransactionUnless(packet.destPort === channel.counterpartyPortIdentifier)
abortTransactionUnless(packet.destChannel === channel.counterpartyChannelIdentifier). SourcePort and 


### `function sendPacket`

interface ChannelEnd {
  state: ChannelState
  ordering: ChannelOrder
  counterpartyPortIdentifier: Identifier
  counterpartyChannelIdentifier: Identifier
  connectionHops: [Identifier]
  version: string
}


interface Packet {
  sequence: uint64
  timeoutHeight: Height
  timeoutTimestamp: uint64
  sourcePort: Identifier
  sourceChannel: Identifier
  destPort: Identifier
  destChannel: Identifier
  data: bytes
}

We specify sourcePort to identify a module on the source chain we will use to send packet. Then we need
to specify what is the destination: this is achieved by the sourceChannel. Note that sourceChannel has a 
semantic of capturing what is the counterParty end, i.e., destPort and destChannel. We don't allow 
sourcePort and sourceChannel to be used as channel end for multiple channels. 
`chanOpenInit` is a way to create channel end. It expresses intention to use this channel end to exchange data
with the module identified with destPort and destChannel. Furthermore, it states that counterParty will be 
verified using connection id. Connection id should capture agreement between modules what initial headers 
are used as a channel root of trust. 

What if instead of connectionId we would specify clientId? Every clientId is a local representation of
the destination chain. It would require `chanOpenTry` to carry clientState that is associated with the chosen
clientId. Therefore, for every channel between chainA and chainB, `chanOpenTry` will need to send clientState.
This is optimised by introducing connection abstraction that is used to establish once agreement between
chains on the initial light client states. Therefore, instead of passing clientState, we just send connectionId
and it is enough information on the reception side to fetch the corresponding clientState. 

- init side says: I want to establish channel with destPort and chainB and my view of chainB is represented
with this clientId. 
- echo side: verify if clientState corresponds to this chain. Pick channelId (or use proposed one) and 
say: I confirm that I will use this channelId to establish the channel with proposed portId/channelId 
(channelId probably sufficient). My view of chainA is this client state (represented by clientId on the chainB).
- ack: verify that clientState used by counterParty module is valid state of chainA and that identifiers and 
version makes sense. Channel is open and set counterPart channel id. 


- preconditions:
    - channel end identified with sourcePort and sourceChannel exists, and it is not in the CLOSED state.
    - sending module owns sourcePort (has corresponding capability)
    - the corresponding connection exists (it is not null) Q: why this is important?. Maybe it makes more 
    sense to know 
    - timeout hasn't expired yet (based on local light client perception of destination chain)
    - packet.sequence == nextSequenceSend Q: why user needs to track sequence number on ordered channels?
    
- postconditions        
    - if preconditions are not satisfied, abort.
    - the amount of tokens sent is equal to the input
    - if source then source account is reduced by the amount and amount of tokens is 
    added to the escrow account; otherwise (if sync) amount of token is burned from the sender account
    
### `function onRecvPacket`

- preconditions:
    - denomination is not native token; if counterparty is source then denomination is native; otherwise it
    is prefixed with source portId/channelId/ 
    - channel is open and only ICS20 modules has access to this channel
    - amount is positive
    - receiver is valid address
    - timeouts are positive
    - escrow account (where sent tokens are locked) exists, and it is controlled by the ICS20 modules
    - if source then amount of tokens in the escrow account is greater or equal to amount
    - if source then denomination is prefixed with counterParty portId/channelId/

- postconditions        
    - if preconditions are not satisfied, error is returned. If error is not nil then ack with failure is 
     created; otherwise it is acc with a success.
    - if source, then sender account is increased by the amount and escrow account reduced by the amount; 
    otherwise amount of new tokens with new denomination (extended by prefix portId/channelId/) is created and added
     to the receiver amount

### `function onAcknowledgePacket` and `onTimeoutPacket`

- preconditions:
    - channel is open and only ICS20 modules has access to this channel
    - ack is valid (success is boolean, error is string, if success then error is not nil)
    - packet is valid
    - escrow account (where sent tokens are locked) exists, and it is controlled by the ICS20 modules
    - if source then amount of tokens in the escrow account is greater or equal to packet.amount
    - denomination is native if source; otherwise it is prefixed with portId/channelId/
    - sender is valid account 

- postconditions        
    - if preconditions are not satisfied, abort. 
    - if source, then sender account is increased by the amount and escrow account reduced by the amount; 
    otherwise amount of new tokens is created and added to the sender amount

    
     
    
        


