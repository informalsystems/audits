
### IF-IBC-03
## ICS04 - Incorrect Properties

**Severity**: Medium  
**Type**: Specification error  
**Difficulty**: Hard   
**Involved artifacts**: [ICS04](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-004-channel-and-packet-semantics)   

### Description

ICS 04 provides a list of 6 ["desired properties"](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics#desired-properties).
The first four of which are misleading or underspecified:

> - The speed of packet transmission and confirmation should be limited only by the speed of the underlying chains. Proofs should be batchable where possible.
Exactly-once delivery

* "Speed" is too vague. 
* The formulation ignores relayers that are the active components in packet transmission. 

> - IBC packets sent on one end of a channel should be delivered exactly once to the other end.

This property are also vague as:

* in the absence of a relayer no packets can be delivered
* ignores timeouts
* unspecific what "sent" means, cf. [IF-IBC-02].

> - No network synchrony assumptions should be required for exactly-once safety. If one or both of the chains halt, packets may be delivered no more than once, and once the chains resume packets should be able to flow again.

* It is unclear what "exactly-once safety" is.
* Network synchrony assumptions (e.g. trusting periods) may be necessary for client safety (ICS 02 and ICS 07). 
* If both chains halt for too long, light clients may not accept headers, and manual (subjective) initialization is needed.

> - On ordered channels, packets should be sent and received in the same order: if packet x is sent before packet y by a channel end on chain A, packet x must be received before packet y by the corresponding channel end on chain B.

It is not clear what "if packet x is sent before packet y by a channel end on chain A" meant in a context where chain A performs invalid transitions: then a packet with sequence number *i* can be sent after *i+1*. If this happens, the IBC implementation may be broken (depends on the relayer).

**Missing properties.** "Safety of communication" is not specified, that is, if the counterparty is valid (and there is not attack), the package received was sent using `SendPacket`.

### Problem Scenarios

Application developer may be lured into the trap of assuming these wrong properties and building their application on 
top of it, which opens a wide range of exploitable attack scenarios, for instance:

- The missing safety property might result in accepting a packet without understanding the risk, and thus 
  substantial financial loss. E.g., if it is a fungible token transfer packet (ICS 20), and 
  the counterparty is Byzantine, I might accept a forged token that is not escrowed anywhere.

- Implying that in all cases of two chains stop operation may continue automatically, may lead to not making the 
application code ready for social recovery.


### Recommendation

Provide more precise properties. Also distinguish between properties between two valid chains, and properties a 
valid chain can expect if the counterparty chain is invalid (Byzantine).


