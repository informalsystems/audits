Clarificiation for valid counterparties.

The introductory [text on packets](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics#receiving-packets) is misleading. After explanation of `SendPacket` it says 

>"The `recvPacket` function is called by a module in order to receive an IBC packet sent on the corresponding channel end on the counterparty chain." 

This could be understood as if `recvPacket` is called as response to a call on `SendPacket` on the other chain. This is not necessarily true if the other chain performs invalid transitions.

Similar comments apply to [acknowledgements](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics#processing-acknowledgements) and [timeouts](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics#sending-end): in all these discussions talking about what happened on the other chain is misleading as it must be preconditioned that the other chain is valid **and** not forked.