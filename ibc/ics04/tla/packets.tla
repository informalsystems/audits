------------- Module packets ------------------

EXTENDS Integers, FiniteSets, Sequences, identifiers, packetdata

VARIABLE
    channels
    error,
    log,
    p,  \* we want to start with generating single packets 
  

Packets == [
    timeoutHeight: integer
    timeoutTimestamp: integer
    sourcePort: Identifiers,
    sourceChannel: Identifiers,
    destPort: Identifiers,
    destChannel: Identifiers,
    data: PacketData
]

WellFormedPacket(packet) ==
    /\ packet.sourcePort /= NullId
    /\ packet.sourceChannel /= NullId
    /\ packet.destPort /= NullId
    /\ packet.destChannel /= NullIdv
 
 INIT ==
     channels = [ x \in {<<NullId, NullId>>} |-> TODOchannel  ]
     