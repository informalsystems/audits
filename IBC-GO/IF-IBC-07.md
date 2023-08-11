
### IF-IBC-07
## ICS20 - Type mismatch for amount packet field between code and spec 
**Severity**: Low  
**Type**: Specification deviation   
**Difficulty**: easy     
**Involved artifacts**: 
[ICS 20](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-020-fungible-token-transfer)

### Description

The ICS20 specification uses uint256 for FungibleTokenPacketData.Amount 

```go
interface FungibleTokenPacketData {
  denomination: string
  amount: uint256
  sender: string
  receiver: string
}
```

The code uses uint64 
```go
type FungibleTokenPacketData struct {
	// the token denomination to be transferred
	Denom string
	// the token amount to be transferred
	Amount uint64
	// the sender address
	Sender string
	// the recipient address on the destination chain
	Receiver string
}
```

The confusion is maybe due the coin type where the amount is a BigInt. 

### Problem Scenarios

The user might send an amount that is a bigger integer than accepted and have his/her transaction abort due to an overflow. 

### Recommendation

Change the spec. 
