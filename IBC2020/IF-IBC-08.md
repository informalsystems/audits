
### IF-IBC-08
## ICS07 - Tendermint Client: wrong usage of unbonding period

**Severity**: Medium  
**Type**: Protocol bug   
**Difficulty**: easy     
**Involved artifacts**: [ICS 07](https://github.com/cosmos/ics/tree/e01da1d1346e578297148c9833ee4412e1b2f254/spec/ics-007-tendermint-client), [`light-clients/07-tendermint/types/misbehaviour_handle.go`](https://github.com/cosmos/cosmos-sdk/blob/6344d626db1fbdba5e0f67425703c1584021bf5b/x/ibc/light-clients/07-tendermint/types/misbehaviour_handle.go#L96)

### Description


In the [code](https://github.com/cosmos/cosmos-sdk/blob/6344d626db1fbdba5e0f67425703c1584021bf5b/x/ibc/light-clients/07-tendermint/types/misbehaviour_handle.go#L96) we observe the following line:

```go
if currentTimestamp.Sub(consState.Timestamp) >= clientState.UnbondingPeriod {
```
It should ensure that the consensus state that is used to verify one of the headers that constitute misbehavior is not too old.

According to the Tendermint Security model, validators in NextValidators of a block (header) with time *t* need to behave 
correctly until *t + TrustingPeriod*. After that time, they may behave arbitrarily (given that they do not appear in as 
NextValidator in a later block.). However here we are checking against the UnbondingPeriod, not the TrustingPeriod, 
where `UnbondingPeriod > TrustingPeriod`. As a result, this check allows nodes that are outside the fault assumption to 
shut down the client.

**Remark.** The implemented misbehavior treatment in the Tendermint Client is not specified in ICS 07. We categorize it 
as "protocol bug" under the assumption that the code line is the result of a protocol design process that was documented 
somewhere else that led to this conclusion, rather than a mistake in the implementation.

### Problem Scenarios

If the age of the `consState` is between *TrustingPeriod* and *UnbondingPeriod* the header will be accepted as base to 
verify one of the conflicting headers that constitutes misbehavior.

During this period, the validators in `consState.NextValidators`
are not considered trustworthy anymore. As we must assume that they behave arbitrary, they can forge the header that is 
part of misbehavior (there is no incentive not to do that). As a result adversarial former validators may shut down 
the client without risking anything.


### Recommendation

- Document and specify the misbehavior treatment, and make explicit timing assumptions. 
- Change the code to
  ```go
  if currentTimestamp.Sub(consState.Timestamp) >= clientState.TrustingPeriod {
  ```
