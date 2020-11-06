# ICS 04

    
## ICS04 invariants

ICS04 allows modules on different chains to exchange packets in a reliable and secure way. 
If channel is ordered, then ordering of packet sent is respected on the delivery.

Modules on different chains need to establish initial trust in the form of trusted header state.
More precisely, given a module A on chainA and a module B on chainB, the module A needs to install 
a trusted header of the chainB that will be used as a source of trusted for the module B on chainB,
and that is used to verify state transitions on the chainB. The same should be true in the opposite
direction.

We specify sourcePort to identify a module on the source chain we will use to send packet. Then we need
to specify what is the destination: this is achieved by the sourceChannel. Note that sourceChannel has a 
semantic of capturing what is the counterParty end, i.e., destPort and destChannel. We don't allow 
sourcePort and sourceChannel to be used as channel end for multiple channels. 
`chanOpenInit` is a way to create channel end. It expresses intention to use this channel end to exchange data
with the module identified with destPort and destChannel. Furthermore, it states that counterParty will be 
verified using given connectionId. ConnectionId should capture agreement between modules what initial headers 
are used as a channel root of trust. 
  
Questions:

- What is exactly meant with "delivered in order sent"? As packets has associated sequence numbers 
we don't need to strictly send them in order (generate packets), we just need to deliver them in 
the order of sequence numbers?
- in ChanOpenTry and ChanOpenAck, what if proofHeight is negative?
- what is a relation between version and counterpartyVersion in ChanOpenTry?Note that it's only used
to check proof of the ChanOpenInit. Then in ChanOpenAck counterpartyVersion is adopted? What is then a point
of version in ChanOpenInit?

## Findings

- in sendPacket, capability appears out of nowhere. It should probably be passed as a parameter. 
- in sendPacket, these two checks seems not necessary:
abortTransactionUnless(packet.destPort === channel.counterpartyPortIdentifier)
abortTransactionUnless(packet.destChannel === channel.counterpartyChannelIdentifier). 
- in chanOpenInit, portCapability is not defined. It should probably be passed as a parameter.
- in ChanOpenInit, len(connectionEnd.GetVersions()) == 1 does not exist in the spec
- in ChanOpenInit, connectionEnd.GetVersions()[0] should support required ordering does not exist in the spec

- in ChanOpenTry ValidateBasic contains business logic: 
L118, msgs.go: if msg.CounterpartyChosenChannelId != "" && msg.CounterpartyChosenChannelId != msg.DesiredChannelId {.
There is a duplicate check in ChanOpenTry 
- spec should be written from the msgHandler perspective, i.e., parameter of the handler should be
message and we should specify msg basic validation and handler logic separately
- are portIds and channelIds defined by the spec? If this is something channel specific, then it is weird that 
we validate counterparty ids (inside channel.go, L57, channel.ValidateBasic)
- in ChanOpenTry found at L117 is the same as found at line 200, so line 200 is redundant.
It seems that at line 200, the check should be about channel capability and if it exists or not.

- bad practise using "" as a special value in the code. It would be better defining it as a constant
- in CounterpartyHops it would be better passing connectionId (or coonectionEnd as it already fetcher before) and not 
channel as a parameter. Then line 281 can be removed.
- counterpartyVersion overwrites local channel version. This does not look like handshake. 

### `function chanOpenInit`

ChanOpenInit(
	ctx sdk.Context,
	order types.Order,
	connectionHops []string,
	portID,
	channelID string,
	portCap *capabilitytypes.Capability,
	counterparty types.Counterparty,
	version string) Capability, error

type Counterparty struct {
	// port on the counterparty chain which owns the other end of the channel.
	PortId string 
	// channel end on the counterparty chain
	ChannelId string `
}

- preconditions:
    - order is ORDERED or UNORDERED
    - connectionHops is sequence of identifiers and its length must be 1
    - portID is valid identifier
    - channelId is valid identifier
    - calling module owns port capability for portID, i.e., portCap is valid capability for portID
    - counterParty.PortID is valid identifier(?)
    - counterParty.ChannelId is valid identifier ("" has special semantics)
    - channelEnd identified with portID, channelID should be nil
    - connectionEnd identified with connectionHops[0] shound not be nil
    - len(connectionEnd.GetVersions()) == 1 // single version of the connection should be negotiated before channel 
    creation is triggered
    - connectionEnd.GetVersions()[0] should support required ordering
    - capability for ChannelCapabilityPath(portID, channelID) does not exist

- postconditions        
    if preconditions hold
    - channelEnd is created with INIT state as passed parameters
    - channelEnd is persisted to the store with (portID, channelID) as keys
    - channel capability is created for name (portID, channelID)
    - nextSequenceSend set to 1 in the store for key (portID, channelID)
    - nextSequenceRecv set to 1 in the store for key (portID, channelID)
    - nextSequenceAck set to 1 in the store for key (portID, channelID)
    else abort

### `function chanOpenTry`

TODO: Define msg and then specify what is done in ValidateBasic and what in the handler. 
The spec should probably be written in that model and not like in the existing version.

func (k Keeper) ChanOpenTry(
	ctx sdk.Context,
	order types.Order,
	connectionHops []string,
	portID,
	desiredChannelID,
	counterpartyChosenChannelID string,
	portCap *capabilitytypes.Capability,
	counterparty types.Counterparty,
	version,
	counterpartyVersion string,
	proofInit []byte,
	proofHeight exported.Height,
) (*capabilitytypes.Capability, error)

- preconditions:
    - order is ORDERED or UNORDERED
    - connectionHops is sequence of identifiers and its length must be 1
    - portID is valid identifier
    - desiredChannelID is valid identifier
    - counterpartyChosenChannelID is "" or equal to desiredChannelID
    - len(proofInit) > 0
    - proofHeight must be non zero (can it be negative?)
    - connectionEnd identified with connectionHops[0] shound not be nil
    - len(connectionEnd.GetVersions()) == 1 // single version of the connection should be negotiated before channel 
    creation is triggered
    - channelEnd identified with (portId, desiredChannelID) does not exist in the store or if it exists (we denote with ch)
    satisfies the following: ch.state == INIT, ch.ordering == order, ch.counterParty == counterParty, 
    ch.connectionHops[0] == connectionHops[0], ch.version == version
    - portCap is valid capability for portID (modules owns portID)
    - connectionEnd identified with connectionHops[0] exists
    - connectionEnd.state == OPEN
    - len(connectionEnd.GetVersions()) == 1
    - connectionEnd.GetVersions()[0] should support required ordering
    - proofInit is a membership proof at height proofHeight for channelEnd ch with the following fields:
      ch.state == Init, ch.ordering == order, ch.counterParty == counterParty, 
      ch.connectionHops == connectionEnd.CounterpartyHops, ch.version == counterpartyVersion    
    
- postconditions        
    if preconditions hold
        - channelEnd is created with TRYOPEN state and passed parameters
        - channelEnd is persisted to the store with (portID, desiredChannelID) as keys
        - channel capability exists for name (portID, desiredChannelID) (if it was already created as part of
        ChanOpenInit it is not recreated)
        - nextSequenceSend set to 1 in the store for key (portID, desiredChannelID)
        - nextSequenceRecv set to 1 in the store for key (portID, desiredChannelID)
        - nextSequenceAck set to 1 in the store for key (portID, desiredChannelID)
    else abort
    
    
### `function chanOpenAck`

func (k Keeper) ChanOpenAck(
	ctx sdk.Context,
	portID,
	channelID string,
	chanCap *capabilitytypes.Capability,
	counterpartyVersion,
	counterpartyChannelID string,
	proofTry []byte,
	proofHeight exported.Height,
)

- preconditions:
    - portID, channelID and counterpartyChannelID are valid identifiers
    - len(ProofTry) > 0
    - proofHeight is not zero
    - channelEnd (ch) identified with portID and channelID exists
    - ch.State in {INIT, TRYOPEN}
    - chanCap is valid channel capability for ChannelCapabilityPath(portID, channelID), i.e., caller has valid channel
    capability for (portID, channelID)
    - ch.Counterparty.ChannelId == "" or ch.Counterparty.ChannelId == counterpartyChannelID
    - connectionEnd identified with channel.ConnectionHops[0] exists and is in OPEN state
    - proofTry is a membership proof at height proofHeight for channelEnd channel with the following fields:
      channel.state == TRYOPEN, channel.ordering == ch.ordering, ch.counterParty == CounterParty(portID, channelID), 
            ch.connectionHops == connectionEnd.CounterpartyHops, ch.version == counterpartyVersion

- postconditions:
    - channel.State = types.OPEN
    - channel.Version = counterpartyVersion
    - channel.Counterparty.ChannelId = counterpartyChannelID
    - persist channel with (portID, channelID) as keys
            

### `function chanOpenConfirm`

func (k Keeper) ChanOpenConfirm(
	ctx sdk.Context,
	portID,
	channelID string,
	chanCap *capabilitytypes.Capability,
	proofAck []byte,
	proofHeight exported.Height,
) error    
    
- preconditions:
    - portID and channelID are valid identifiers
    - len(proofAck) > 0
    - proofHeight is not zero
    - channelEnd (ch) identified with portID and channelID exists
    - ch.State == TRYOPEN
    - chanCap is valid channel capability for ChannelCapabilityPath(portID, channelID), i.e., caller has valid channel
    capability for (portID, channelID)
    - connectionEnd identified with channel.ConnectionHops[0] exists and is in OPEN state
    - proofAck is a membership proof at height proofHeight for channelEnd channel with the following fields:
      channel.state == OPEN, channel.ordering == ch.ordering, channel.counterParty == CounterParty(portID, channelID), 
      channel.connectionHops == connectionEnd.CounterpartyHops, channel.version == ch.Version

- postconditions:
    - channel.State = OPEN
    - persist channel with (portID, channelID) as keys
            
### `function chanCloseInit`

func (k Keeper) ChanCloseInit(
	ctx sdk.Context,
	portID,
	channelID string,
	chanCap *capabilitytypes.Capability,
)

 preconditions:
    - portID and channelID are valid identifiers
    - channelEnd (ch) identified with portID and channelID exists
    - ch.State != CLOSED
    - chanCap is valid channel capability for ChannelCapabilityPath(portID, channelID), i.e., caller has valid channel
    capability for (portID, channelID)
    - connectionEnd identified with channel.ConnectionHops[0] exists and is in OPEN state

- postconditions:
    - channel.State = CLOSED
    - persist channel with (portID, channelID) as keys

### `function chanCloseConfirm`

func (k Keeper) ChanCloseConfirm(
	ctx sdk.Context,
	portID,
	channelID string,
	chanCap *capabilitytypes.Capability,
	proofInit []byte,
	proofHeight exported.Height,
) error

preconditions:
    - portID and channelID are valid identifiers
    - channelEnd (ch) identified with portID and channelID exists
    - ch.State != CLOSED
    - chanCap is valid channel capability for ChannelCapabilityPath(portID, channelID), i.e., caller has valid channel
    capability for (portID, channelID)
    - connectionEnd identified with channel.ConnectionHops[0] exists and is in OPEN state
    - len(proofInit) > 0
    - proofHeight is not zero
    - proofInit is a membership proof at height proofHeight for channelEnd channel with the following fields:
      channel.state == CLOSED, channel.ordering == ch.ordering, channel.counterParty == CounterParty(portID, channelID), 
          channel.connectionHops == connectionEnd.CounterpartyHops, channel.version == ch.Version

- postconditions:
    - channel.State = CLOSED
    - persist channel with (portID, channelID) as keys





