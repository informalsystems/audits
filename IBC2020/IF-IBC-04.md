
### IF-IBC-04
## ICS18 - Relayer underspecified

**Severity**: Low  
**Type**: Unclear specification   
**Difficulty**: medium     
**Involved artifacts**: [ICS 18](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-018-relayer-algorithms)   

### Description

The relayer is the active component in IBC. It is responsible to submit datagrams in time, and in observing the state of 
the chains it connects. There are some points that need clarification

 >There are implicit ordering constraints. 
 
 The order in which datagrams are submitted is crucial to ensure progress in IBC. An exhaustive representations of these 
 constraints need to be made explicit.

 That these constraints are not explicitly provided leads to misleading statements in the same document, as the following:

 > "Race conditions": "if two relayers do so, the first transaction will succeed and the second will fail." 
 
 This statement is only true if both relayers adhere to these "implicit" ordering constraint that the header need to be installed first. It might be that the first relayer fails, then the header is installed, then the second relayer succeeds.

In addition, timeout handling is not discussed.

### Problem Scenarios

- If the relayer has to create datagrams for two packets on an ordered channel with sequence number 4 and 5, and submits 
  them in wrong order (5 before 4), the [check](https://github.com/cosmos/cosmos-sdk/blob/ba4bc4b5c86e56baa4f2589480ff7aa493222655/x/ibc/core/04-channel/keeper/packet.go#L259) in the packet handler will fail on both packets.

- The above scenarios considers just one ICS (ICS 04), while the example given in 
  [ICS 18](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-018-relayer-algorithms#ordering-constraints) (header before packet) highlights an ordering between different ICSs. They are especially hard to infer.

Having these order constraints underspecified might lead to relayer implementations that:

- from the protocol viewpoint do not ensure liveness in communication, 
- from the economic viewpoint results in transaction fees being spent unnecessarily.


### Recommendation

What complicates the situation is that these ordering constraints involve concurrency effects that should be 
mitigated (serialized) at the relayer. Such issues are typically hard to reproduce or debug.

- Make explicit all the ordering constraints.
- Provide test cases that involve corner cases.
- Specify the required behavior of the Relayer for timeout handling.
