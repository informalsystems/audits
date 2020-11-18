## [IF-IBC-REFUND-01]
## ICS20 - Refund logic differs between code and specification

Severity: Unclear  
Type: Specificaion deviation  
Difficulty: Unclear  
Involved artifacts: [ICS 20](), [Code]()

### Description

In the specification ICS20 `recvPacket` in the case where there is an error within the bank module (`TransferCoins` and `Mintcoins`), an acknowledgement with error corde is generated. As a result, at the sending chain the function `onAcknowledgePacket` is executed (assuming normal operation with a reliable relayer) which in turn performs `refund`.

In the [implementation](), in case of an error the bank module panics, the transaction is aborted. In case of not other events (e.g., later a packet adds money to some accout which results in the original packet going through upon retry without panic), on the sender chain, the function `onTimeoutPacket` is executed which in turn performs `refund`.

### Problem Scenarios

It seems that the intuition of the logic in the specification is to highlight that an acknowledgement value can be used to control the application. Instead of refunding, one might thing of retrying sending. From a design viewpoint, separating application-level acknowledgement codes from more low level aborts seems advantageous. However, it seems as if the bank module does not provide this fine-grained distinction.


### Recommendation

- Change specification to allign with code.
- Due to the discrepance it appears that [OnAcknowledgement]() is dead code.
