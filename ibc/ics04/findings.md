# ICS 04

XXX : Howd the links become 286e9b? previous we were on 82f15f306e

Note the split packet functions were combined in
https://github.com/cosmos/cosmos-sdk/pull/7813 . but they still run before the
module handlers, unlike the spec

We need to update to a more recent commit since things like ^ got merged

## Spec does not match code

- In the specification of the function
[`timeoutPacket`](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics#sending-end)
there is a check `(packet.timeoutHeight > 0 && proofHeight >=
packet.timeoutHeight)` while the corresponding
[check](https://github.com/cosmos/cosmos-sdk/blob/286e9bfbefabe215da11b27ca7e41f72c28bedbb/x/ibc/core/04-channel/keeper/packet.go#L73)
in the code checks for strictly greater
- The [figure](https://github.com/cosmos/ics/blob/master/spec/ics-004-channel-and-packet-semantics/packet-state-machine.png) does not capture the flow of the acknowledgements
- RecvPacket and WriteReceipt are combined as RecvPacket in the spec and they
  together take place after the module's recvPacket. In the
  code, they are split up, and they sandwich the call to the module's recvPacket. 
  Can the module's handler run first, like the spec? Or do we need to update the
  spec?
- Similarly for AcknowledgePacket and AcknowledgementExecuted.

Error handling:
- In the spec of recvPacket the call `provableStore.get(nextSequenceRecvPath(packet.destPort,
  packet.destChannel))` may not produce an error, which the code
  checks for one
- in the spec recvPAcket returns a packet while in the [implementation](https://github.com/cosmos/cosmos-sdk/blob/286e9bfbefabe215da11b27ca7e41f72c28bedbb/x/ibc/core/04-channel/keeper/packet.go#L138)
  it returns error

More generally if the spec assumes an operation is infalible but the SDK uses a
method that can return an error, should we panic on that error?

## Code

- connectionEnd.GetState should return `State`, not `int32` - else its always cast back to int32, eg. [`if connectionEnd.GetState() != int32(connectiontypes.OPEN)
  {`](https://github.com/cosmos/cosmos-sdk/blob/286e9bfbefabe215da11b27ca7e41f72c28bedbb/x/ibc/core/04-channel/keeper/packet.go#L179). Then these casts to int32 can be removed
- the end sequences of timeoutonclose and timeoutPacket are identical from
  `switch channel.Ordering {`. Consider deduplicating
- Stale comment: AcknowledgePacket docstring states intention to be run in the anteHandler. This doesn't happen
- RecvPacket should AuthenticateCap. [This
comment](https://github.com/cosmos/cosmos-sdk/blob/82f15f306e8a6a2e9ae3e122c348b579c43a3d92/x/ibc/core/04-channel/keeper/packet.go#L156)
about it being done in the AnteHandler is not correct. Fixed by     

## To be discussed


- [this](https://github.com/cosmos/cosmos-sdk/blob/286e9bfbefabe215da11b27ca7e41f72c28bedbb/x/ibc/core/04-channel/keeper/packet.go#L207)
  checks whether sequence number has been received before. I guess
  there is an expectation that the sending chain uses each sequence
  number only once. faults?
    - EB: yes, each sequence number only once. what do you mean by faults here? 
  
