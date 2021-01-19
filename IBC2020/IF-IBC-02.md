
### IF-IBC-02
## Faulty semantics underspecified

**Severity**: Medium  
**Type**: Unclear Specification  
**Difficulty**: Unclear  
**Involved artifacts**: [ICS 02](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-004-channel-and-packet-semantics), [ICS 03](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-003-connection-semantics), [ICS 04](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-004-channel-and-packet-semantics), [ICS 20](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-020-fungible-token-transfer)

### Description

Throughout the documents, the environment in which the functions are called are often unclear and sometimes misleading. 
For instance, in ICS 04 the specification of the function `sendPacket` is followed by the description of 
[receiving packets](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics#receiving-packets). 
It starts with 

>The `recvPacket` function is called by a module in order to receive an IBC packet sent on the corresponding channel end on the counterparty chain.

In the context of the specification, an application developer is led to believe that "sent on the corresponding channel" 
means that `sendPacket` has been executed at the counterpart chain.

However, IBC is designed also to provide some services if the counterparty chain performs invalid transitions. 
This should be made explicit so that an application developer is not lured into the trap of assuming a friendly 
environment. It should be distinguished between semantics to expect from a valid counterparty and 
semantics to expect (or not expect) from an invalid (Byzantine) counterparty.


### Problem Scenarios

In ICS 20, the fungible token transfer, if a receiver receives a token with prefixed denomination, the validity and 
fungibility of a token depends on the validity of all the chains encoded in the prefix. In particular, an 
invalid chain B can send an arbitrary number of prefixed chain A tokens to chain C out of thin air, while none 
of these tokens are escrowed at A. A user not aware of the Byzantine semantics of `recvPacket` may not be aware of this, 
which hinders a proper risk assessment, and development of application-level counter measures. Not taking this into 
account opens an area of attack that may lead to substantial financial loss.

### Recommendation

- In all function definitions, distinguish between valid and invalid counterparty semantics.
- In the discussion be precise about what is meant when referring to actions on the counterparty. 
  E.g., make clear what is meant by "sent" in "IBC packet sent on the corresponding channel end on the counterparty chain".
