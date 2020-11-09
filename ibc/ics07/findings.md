-
  [headers](https://github.com/cosmos/ics/tree/master/spec/ics-007-tendermint-client#headers)
   - contain height in unit64 while some lines above it is defined as
     (epoch,height) pair
   - next validator set missing
   - actually is a signed header
   
  
-
  [misbehavior](https://github.com/cosmos/ics/tree/master/spec/ics-007-tendermint-client#misbehaviour)
  is outdated I guess.
  
  
- [Note on "would-have-been-fooled
  logic](https://github.com/cosmos/ics/tree/master/spec/ics-007-tendermint-client#note-on-would-have-been-fooled-logic). Out
  of nowhere this text appears. One should really take an effort to
  structure the information in the ICSs. Right now there is hardly any
  structure. 
  
- [consensus
  state](https://github.com/cosmos/ics/tree/master/spec/ics-007-tendermint-client#consensus-state),
  which is called header or lightblock in real life, misses next
  validator set.

- [Misbehavior](https://github.com/cosmos/ics/tree/master/spec/ics-007-tendermint-client#misbehaviour-predicate)
  this is not ensured to work does not work. huge difference to
  implementation
  

-
  [unbondingperiod](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/misbehaviour_handle.go#L125)
  shoud be `TrustingPeriod`

- [didn't find the veification function](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/misbehaviour_handle.go#L142)
