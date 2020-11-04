# ICS 20

## Spec does not match code

- In the specification of the function
[`timeoutPacket`](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics#sending-end)
there is a check `(packet.timeoutHeight > 0 && proofHeight >=
packet.timeoutHeight)` while the corresponding
[check](https://github.com/cosmos/cosmos-sdk/blob/286e9bfbefabe215da11b27ca7e41f72c28bedbb/x/ibc/core/04-channel/keeper/packet.go#L73)
in the code checks for strictly greater



## To be discussed

- Is this OK [`if connectionEnd.GetState() != int32(connectiontypes.OPEN)
  {`](https://github.com/cosmos/cosmos-sdk/blob/286e9bfbefabe215da11b27ca7e41f72c28bedbb/x/ibc/core/04-channel/keeper/packet.go#L179)
  
- [this](https://github.com/cosmos/cosmos-sdk/blob/286e9bfbefabe215da11b27ca7e41f72c28bedbb/x/ibc/core/04-channel/keeper/packet.go#L207)
  checks whether sequence number has been received before. I guess
  there is an expectation that the sending chain uses each sequence
  number only once. faults?
  
- In the spec of recvPacket the call
  `provableStore.get(nextSequenceRecvPath(packet.destPort,
  packet.destChannel))` may not produce an error, which the code
  checks for one.
  
- in the spec recvPAcket returns a packet while in the [implementation](https://github.com/cosmos/cosmos-sdk/blob/286e9bfbefabe215da11b27ca7e41f72c28bedbb/x/ibc/core/04-channel/keeper/packet.go#L138)
  it returns error
