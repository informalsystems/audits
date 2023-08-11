
### IF-IBC-01
## ICS20 - Refund logic differs between code and specification 

**Severity**: Medium  
**Type**: Specification deviation  
**Difficulty**: Unclear  
**Involved artifacts**: [ICS 20](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-020-fungible-token-transfer), [applications/transfer/module.go](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/applications/transfer/module.go)

### Description

In the specification ICS20 `recvPacket` in the case where there is an error within the bank module 
(`TransferCoins` and `Mintcoins`), an acknowledgement with error code is generated. As a result, at the sending chain 
the function `onAcknowledgePacket` is executed with a "non-success" code (assuming "normal" operation with a reliable 
relayer), which in turn calls `refund`.

In the [implementation](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/applications/transfer/keeper/relay.go#L284), 
in case of an error, the bank module panics, the transaction is aborted. In case of no other events 
(e.g., later a packet removes money from some account which results in the original packet going through upon 
retry without panic), on the sender chain, the function `onTimeoutPacket` is executed which in turn performs `refund`.

### Problem Scenarios

It seems that the intuition of the logic in the specification is to highlight that an acknowledgement value can be 
used to control the application. For instance, instead of refunding, one might think of retrying sending. 

From a design viewpoint, separating application-level acknowledgement codes from more low level aborts seems 
advantageous. However, it seems as if the bank module does not provide this fine-grained distinction.


### Recommendation

The easiest fix would be to 
- Change specification to align with code.
- Due to the discrepancy it appears that no acknowledgement with a code different from "result" is currently sent. 
  If this was true, the error branch in 
  [OnAcknowledgementPacket](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/applications/transfer/keeper/relay.go#L312) 
  would be unreachable code. We suggest to check that, and if this is the case, it should be removed from the 
  specification and the code.

However, as ICS 20 also will serve as a template for future IBC applications, a clearer separation between 
application-level errors and infrastructure roll-backs (and panics) would be advantageous. For that purpose we suggest 
a more robust implementation of token transfer that does not rely on the bank panicking.
