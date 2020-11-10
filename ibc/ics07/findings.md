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

- [not sure where the data structure is defined
  (TrustedHeight)](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/update.go#L52). [here](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/tendermint.pb.go#L199)
  it is undocumented in the spec
  
-
  [TrustedValidators](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/tendermint.pb.go#L200)
  undocumented in the spec. there are 11 lines of comments in the
  code. that should be explained in the spec.
  
- who is supposed to submit the evidence? The relayer? I didn't find
  that it is specified how to do that.
  
  
- [I have no idea what that
  is](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/core/02-client/proposal_handler.go)
  
- [genesis is not discussed in
  ICSs](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/core/02-client/genesis.go)
  
- [not sure this is
  specified](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/core/02-client/types/height.go#L19)
  
- [why not return within the
    if?](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/core/02-client/types/height.go#L59)
	
- [why not
      `splitStr[0]`](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/core/02-client/types/height.go#L163). and
      why operate on height as strings?
	  
- [upgrade unspecified in
        spec](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/core/02-client/types/msgs.go#L15). IT
        is only discussed in ICS07
		
  
-
  [`VerifyClientState`](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/client_state.go#L169)
  not in spec
  
  
- [error handling not in
  spec](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/client_state.go#L224)xs
  
  
- [error handling not in
  spec](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/client_state.go#L229)
  
- [latest height and frozen not
    checked](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/client_state.go#L208). that
    is the case in all implementation of Verify functions
	
- not sure what assert means in [state verification
  functions](https://github.com/cosmos/ics/tree/master/spec/ics-007-tendermint-client#state-verification-functions). Is
  it supposed to return an error or an `sdkerrors.Wrapf`?
  
- [call to tendermint in go verify
  function](https://github.com/cosmos/cosmos-sdk/blob/90e9370bd80d9a3d41f7203ddb71166865561569/x/ibc/light-clients/07-tendermint/types/update.go#L158)
  
  
