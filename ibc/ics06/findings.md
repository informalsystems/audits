# ICS 006

- there is a [spec](https://github.com/cosmos/cosmos-sdk/tree/master/x/ibc/light-clients/06-solomachine/spec) in the code repo

- quite nice [pre- and
  postconditions](https://github.com/cosmos/cosmos-sdk/blob/master/x/ibc/light-clients/06-solomachine/spec/01_concepts.md#updates-by-header)
  also
  [here](https://github.com/cosmos/cosmos-sdk/blob/master/x/ibc/light-clients/06-solomachine/spec/03_state_transitions.md). Is
  this just a copy?
  
- does not allow to install older [headers](https://github.com/cosmos/cosmos-sdk/blob/fe8a891f11dcefe708e43d53549beec808f98687/x/ibc/light-clients/06-solomachine/types/update.go#L47)
  
  
- naming in
  [spec](https://github.com/cosmos/ics/tree/master/spec/ics-006-solo-machine-client#validity-predicate)
  does not match
  [implementation](https://github.com/cosmos/cosmos-sdk/blob/fe8a891f11dcefe708e43d53549beec808f98687/x/ibc/light-clients/06-solomachine/types/update.go#L17)
  
- the governance proposal is undocumented everywhere

- check for [inequality of
  misbehavior](https://github.com/cosmos/cosmos-sdk/blob/fe8a891f11dcefe708e43d53549beec808f98687/x/ibc/light-clients/06-solomachine/types/misbehaviour_handle.go#L33)
  is claimed to happen by the 02-client keeper. (the assertion might
  be removed from ICS006 function definition)
  
  
- Why do the
  [Verify](https://github.com/cosmos/ics/tree/master/spec/ics-006-solo-machine-client#state-verification-functions)
  functions have side effects
  (`clientState.consensusState.sequence++`)? This is not the case in
  ICS002.
  

