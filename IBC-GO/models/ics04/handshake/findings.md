# ICS 04

## Spec does not match code

- in the [spec](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics#packet-flow--handling)
in function `sendPacket`, `capability` appears out of nowhere. It should probably be passed as a function parameter. 

- in the [spec](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics#opening-handshake)
in function `chanOpenInit`, `portCapability` is not defined. It should probably be passed as a parameter.

- in the [spec](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics#opening-handshake)
in function `chanOpenInit`, `len(connectionEnd.GetVersions()) == 1` check does not exist in the spec, but exist in the 
[code](https://github.com/cosmos/cosmos-sdk/blob/fe8a891f11dcefe708e43d53549beec808f98687/x/ibc/core/04-channel/keeper/handshake.go#L59)
. Also this [check](https://github.com/cosmos/cosmos-sdk/blob/fe8a891f11dcefe708e43d53549beec808f98687/x/ibc/core/04-channel/keeper/handshake.go#L67) 
does not exist in the spec.

- spec will probably more understandable if written from the msgHandler perspective, i.e., parameter of the handler should be
message and we should specify msg basic validation and handler logic separately. It will be also
more aligned with the implementation. 


## Questions

- What is exactly meant with "packets delivered in order sent"? As packets have associated sequence numbers 
we don't need to strictly send them in order (generate packets), we just need to deliver them in 
the order of sequence numbers?

- What is a relation between `version` and `counterpartyVersion` in `ChanOpenTry`?Note that it's only used
to check the proof of the `ChanOpenInit`. Then in `ChanOpenAck` `counterpartyVersion` is adopted? What is then a point
of version in `ChanOpenInit`?


## Code improvements


- Basic [validation](https://github.com/cosmos/cosmos-sdk/blob/fe8a891f11dcefe708e43d53549beec808f98687/x/ibc/core/04-channel/types/msgs.go#L118) 
of `MsgChanOpenTry` contains business logic. The same check is done 
also [here](https://github.com/cosmos/cosmos-sdk/blob/fe8a891f11dcefe708e43d53549beec808f98687/x/ibc/core/04-channel/keeper/handshake.go#L162)
 
- in `ChanOpenTry` function, `found` 
at [line](https://github.com/cosmos/cosmos-sdk/blob/fe8a891f11dcefe708e43d53549beec808f98687/x/ibc/core/04-channel/keeper/handshake.go#L117) 
is the same as `found` 
at [line](https://github.com/cosmos/cosmos-sdk/blob/fe8a891f11dcefe708e43d53549beec808f98687/x/ibc/core/04-channel/keeper/handshake.go#L200), 
so the latter is redundant. As `found` variable is overwritten several times, renaming of this variable 
is needed to simplify the logic. 

- Using "" as a special value 
(see [line](https://github.com/cosmos/cosmos-sdk/blob/fe8a891f11dcefe708e43d53549beec808f98687/x/ibc/core/04-channel/keeper/handshake.go#L162))
seems like bad practice. It would probably be better defining it as a constant.

- in [function](https://github.com/cosmos/cosmos-sdk/blob/fe8a891f11dcefe708e43d53549beec808f98687/x/ibc/core/04-channel/keeper/handshake.go#L19)
it might be better passing `connectionId` or `conectionEnd` as it already fetched at the calling point (for example
see [line](https://github.com/cosmos/cosmos-sdk/blob/fe8a891f11dcefe708e43d53549beec808f98687/x/ibc/core/04-channel/keeper/handshake.go#L173)) 
instead of `channel`. 
Then [line](https://github.com/cosmos/cosmos-sdk/blob/fe8a891f11dcefe708e43d53549beec808f98687/x/ibc/core/04-channel/keeper/handshake.go#L282) can be removed.
