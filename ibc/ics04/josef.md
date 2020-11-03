# Notes on ICS004 - Packetas

- Why is `recvPacket` and `writeAcknowledgement` separated

- ?? Acknowledging packets is not required; however, if an ordered
  channel uses acknowledgements, either all or no packets must be
  acknowledged (since the acknowledgements are processed in
  order). Note that if packets are not acknowledged, packet
  commitments cannot be deleted on the source chain. Future versions
  of IBC may include ways for modules to specify whether or not they
  will be acknowledging packets in order to allow for cleanup.
  
- ?? `writeAcknowledgement` does not check if the packet being acknowledged
  was actually received, because this would result in proofs being
  verified twice for acknowledged packets. This aspect of correctness
  is the responsibility of the calling module. The calling module MUST
  only call writeAcknowledgement with a packet previously received
  from recvPacket.

- In the case of an ordered channel, timeoutPacket checks the
  recvSequence of the receiving channel end and closes the channel if
  a packet has timed out.
  
- In the case of an unordered channel, timeoutPacket checks the
absence of the receipt key (which will have been written if the packet
was received). Unordered channels are expected to continue in the face
of timed-out packets.


- `>` vs. `>=` in `timeoutPacket`
```
(packet.timeoutHeight > 0 && proofHeight >= packet.timeoutHeight) ||
(packet.timeoutTimestamp > 0 &&
connection.getTimestampAtHeight(proofHeight) > packet.timeoutTimestamp))
```

- TODO: have a look at `connection.verifyPacketReceiptAbsence`
- TODO: have a look at `connection.verifyNextSequenceRecv` 

- The `timeoutOnClose` function is called by a module in order to
  prove that the channel to which an unreceived packet was addressed
  has been closed, so the packet will never be received (even if the
  timeoutHeight or timeoutTimestamp has not yet been reached).  
  **What about reopening?**
  
- Can I reopen a channel? What about the expectations
    * Can I reopen an ordered channel as unordered? vice versa?
	
- Problems due to distribution/concurrency discussed [here](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics#reasoning-about-race-conditions)

