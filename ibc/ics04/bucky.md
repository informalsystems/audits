
Findings:

RecvPacket should AuthenticateCap. [This comment](https://github.com/cosmos/cosmos-sdk/blob/82f15f306e8a6a2e9ae3e122c348b579c43a3d92/x/ibc/core/04-channel/keeper/packet.go#L156) about it being done in the AnteHandler is not correct.

TODO
- look closely at how time is encoded - ie:
    `if packet.GetTimeoutTimestamp() != 0 && uint64(ctx.BlockTime().UnixNano()) >= packet.GetTimeoutTimestamp() {`

Notes

why is sequence number an application level concern?

SendPacket:
- should be a connectionKeeper.GetLatestHeight

Inventory of x/capability use in ICS04:

ics04:
- ChanOpenInit calls NewCap
- ChanOpenTry calls NewCap or GetCap
- ChanOpenAck calls AuthCap
- ChanOpenConfirm calls AuthCap
- ChanCloseInit, ChanCloseConfirm calls AuthCap
- LookupModuleByChannel calls LookupModules and GetModuleOwners
- SendPacket, WriteReceipt, AcknowledgementExecuted calls AuthCap
- TimeoutExecuted, TimeoutOnClose, calls AuthCap
- The following dont check caps: RecvPacket, WriteAcknowledgement, AcknowledgePacket, TimeoutPacket


calls to host.ChannelCapabilityPath(packet.GetDestPort(), packet.GetDestChannel())
- should just be a function of the channel directly ... otherwise switching between dest and source :(

