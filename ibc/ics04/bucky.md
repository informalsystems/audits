why is sequence number an application level concern?

SendPacket:
- should be connectionKeeper.GetLatestHeight

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

