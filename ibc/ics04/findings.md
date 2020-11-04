# ICS 20

## Spec does not match code

- In the specification of the function
[`timeoutPacket`](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics#sending-end)
there is a check `(packet.timeoutHeight > 0 && proofHeight >=
packet.timeoutHeight)` while the corresponding
[check](https://github.com/cosmos/cosmos-sdk/blob/286e9bfbefabe215da11b27ca7e41f72c28bedbb/x/ibc/core/04-channel/keeper/packet.go#L73)
in the code checks for strictly greater
