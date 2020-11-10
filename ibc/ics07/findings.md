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
  implementation. each header storest a trustingheight. it needs to be
  on the consensus state.
  

-
  [unbondingperiod](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/misbehaviour_handle.go#L125)
  shoud be `TrustingPeriod`

- [didn't find the veification function](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/misbehaviour_handle.go#L142)

- [only allows newer headers to be
  installed](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/update.go#L123)
  OK. just a check that trustedheight is smaller than own height

- [should that be
  height?](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/update.go#L123)
  ok. but comment above talks about consensus state. that is a bit inprecise

- [OK. only called after consensus state is obtained. if this is true we have a
  situation](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/update.go#L88)
  
  
-
  [upgrades](https://github.com/cosmos/ics/tree/master/spec/ics-007-tendermint-client#upgrades)
  are tendermint specific and not mentioned in ICS002. who calls `upgradeClientState`

