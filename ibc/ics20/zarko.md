# ICS 20

## SDK related things to check

- atomicity: all messages in a transaction should fully succeed or transaction should be rolled back. 
We should check if error handling is properly done, so we don't add up with a case where 
transition is partially executed. 

- determinism: state transitions must be deterministic.

- integer arithmetics: check for overflows.

Ideally, a tool can help us to check those properties.

## Differences between code and spec

- FungibleTokenPacketData: amount is uint256 in spec and uint64 in the code.

- PortID = "transfer" in keys.go and in the spec it binds to "bank"

- `onChanOpenInit`:
spec is missing this check:
// Require portID is the portID transfer module is bound to
boundPort := am.keeper.GetPort(ctx)
	if boundPort != portID {
		return sdkerrors.Wrapf(porttypes.ErrInvalidPort, "invalid port: %s, expected %s", portID, boundPort)
	}

- This code is also not covered by the spec:

// Claim channel capability passed back by IBC module
	if err := am.keeper.ClaimCapability(ctx, chanCap, host.ChannelCapabilityPath(portID, channelID)); err != nil {
		return err
	}

- This line of the spec 
    // allocate an escrow address
    `channelEscrowAddresses[channelIdentifier] = newAddress()`
  does not exist in the code.
  
- Is `channelIdentifier` sufficient to identify escrow address? Who should be able
  to control escrow address? Or it should be `channelIdentifier` and `portIdentifier`?
  Or it should be just `portIdentifier`.  

- In the spec it creates escrow address both on `onChanOpenInit` and on
  `onChanOpenTry`. Is this ok? What if relay invokes `onChanOpenInit` and on
  `onChanOpenTry` on the same channel end? `onChanOpenTry` will not fail if called
  after `onChanOpenInit`, therefore, according to the spec, new escrow address is
  created (although added to the map, i.e., overwriting the previous one so that's
  probably not a problem.
  
## Questions

- Why we need to specify `channel/port ids` when we are sending packet? Isn't this 
ICS20 internal detail?
- In `onRecvPacket` prefix should contain "/" at the end.
- How minting vouchers can fail if balance insufficient (written in spec in `onRecvPacket`)?
- There are no acks created in onRecvPacket in the code, while it exists at the spec level?
Most probably at the code level error is returned and this is written as an ack, i.e., if nil
then it is success ack, otherwise failed ack.
 
    
## ICS20 invariants

- ICS20 allows modules A and B that are on different chains need to send tokens to each other.
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

    
     
    
        


