# Findings 

- x/capability: GetCapability deletes capabilities unexpectedly - https://github.com/cosmos/cosmos-sdk/issues/7805

    - Related: NewCapability does not respect rollback semantics. It maintains an in memory `capMap`
from index to ocap. Ideally this would use the memory store, which does support
roll back semantics, but stores operate on []bytes, and the unforgability of
ocaps means we cant marshal them to bytes and back - we'd need a more general
purpose store object which the SDK doesn't have. Thus GetCapability attempts to
catch and detect stale state in the capMap that should have been rolled back but
wasn't

- sk.NewCapability calls addOwner, which should not be able to error. maybe this should panic? there
shouldn't already be owners if we're calling New

- Fwd/Rev creation logic is repeated 3 times. deduplicate

- possible unsafety: malicious application modules can call portKeeper.LookupModuleByPort and get capabilities they don't own 


Missing Test Coverage:
- CapabilityOwners.Get

Tooling opportunities:
- ensure every call to store.Get checks for empty results and handles them appropriately.




## Notes

modules get their own capability keepers - ie. "scoped".

but they all share a common persistentKey (persistent store), memKey (memory story), and capMap (memory map)

InitializeAndSeal - no new scoped keepers

--

app.go

scope one keeper to the IBC module and one to the transfer module

why is CapabilityKeeper a pointer?

capability owner is a module + name

capability is reference to struct{int}

--- 

what is the threat model in which we have to seal the keeper?

modules can only create local capabilities.

new capabilities are prefixed with module name - can't be changed after creation.

no 2 scoped keepers can have the same name.


AuthenticateCapability uses the pointer value in the fwd lookup to ensure the given cap is known and matches the name

spec/01_concepts.md: the calling module must not call ClaimCapability after NewCapability - 
	- note transferkeeper.BindPort calls NewCapabiltiy which returns a cap owned by the ics05 module. then its claimed also by transfer module
	- so transferkeeper.BindPort creates a new cap with two owners:
		- module:ibc, name:ports/transfer
		- module:transfer, name:ports/transfer
	- ie. the port module creates the cap, and then gives it to the transfer module, which calls ClaimCap

---

capability use in ibc/core:

only the scopedKeeper used only in ics05 and ics04

ics05:
- BindPort calls NewCap
- Authenticate calls AuthenticateCap
    - called in channel/keeper/handshake
- LookupModuleByPort calls LookupModules

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

--- 

simapp

we only use one memkey. why bother having a memkeys map if we only use one? whats the use case for more than 1? ie. more than one capabilitykeeper?



