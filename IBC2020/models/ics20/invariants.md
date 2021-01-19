# ICS 20

## SDK related things to check

- atomicity: all messages in a transaction should fully succeed or transaction should be rolled back. 
We should check if error handling is properly done, so we don't add up with a case where 
transition is partially executed. 

- determinism: state transitions must be deterministic.

- integer arithmetics: check for overflows.

Ideally, a tool can help us to check those properties.

    
## ICS20 invariants

ICS20 allows modules A and B that are on different chains need to send tokens to each other.
The communication channel between ICS20 modules is established by relying on unordered IBC channel. 
There is a single channel established between ICS20 modules on two chains used for 
communication.


### `function createOutgoingPacket`

- preconditions:
    - denomination is native if source; otherwise it is prefixed with portId/channelId/
    - channel handshake has been triggered and only ICS20 modules has access to this channel
    - amount is positive
    - sender is valid address 
    - timeouts are positive
    - escrow account (where sent tokens are locked) exists, and it is controlled by the ICS20 modules
    - amount of tokens in the sender account is greater or equal to amount

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

    
     
    
        


