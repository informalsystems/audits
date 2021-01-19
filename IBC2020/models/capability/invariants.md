# x/capability

The SDK is designed to operate in an environment where applications are composed
of many different *modules*. Each module is a distinct component of the
application, typically with its own *store* and its own set of messages and
handlers that can be triggered by transactions. Modules may be written by
distinct development teams, and thus certain modules in an application may be faulty or malicious.
The SDK adopts the [Principle of Least Privelege](https://en.wikipedia.org/wiki/Principle_of_least_privilege) 
where ever possible to minimize the damage that can be done by a faulty module.

Access control via the PoLP is well implemented through the [object
capability](https://en.wikipedia.org/wiki/Object-capability_model) model.
Object capabilitys (ocaps) are unforgeable references that permit
their owners to take certain actions. An agent can only obtain an ocap by 
creating it themselves, or by receiving it from another agent.

The SDK already uses ocaps to control how modules can access stores.
Access to each store (the bank store, the staking store, the governance store,
the ibc store, etc.) is mediated by an ocap (a Go pointer), and modules can only
access the stores associated with the ocaps they are given. Keepers are wrappers
around these ocaps that further restrict the actions that can be taken. All of
this access control is specified statically at startup time in `app.go`, where ocaps are
created, granted to certain modules in the form of keepers, and associated with
stores.

At the IBC level, the resources we need access control for are ports
and channels, since we want to ensure that only one module can bind a port (ie.
initiate channels on that port), and that only the module which owns a channel can act on that channel.
This allows a module on one chain to establish channels to a particular module on another
chain, while limitting the damage that can be done by other modules, on either chain, which
may be faulty or malicious.

For static modules built at compile time, this can be achieved using the
existing static ocap system, where modules bind ports at initialization.
However, we'd like to support dynamic modules, where new modules can be created
at runtime by sending code to the blockchain - ie. smart contracts.
Such modules, or smart contracts, could not be granted capabilities statically
during process initialization as they weren't created yet. Hence the need for a
dynamic ocap system, which is implemented in `x/capability`.


`x/capability` implements ocaps using a global 
CapabilityKeeper, which tracks all created ocaps and their owners.
An owner is a pair (Module, Name), where Module is the module that owns the ocap,
and Name is the module's local name for the ocap. A module `M` is given a
ScopedKeeper (derived from CapabilityKeeper) which can only create ocaps with owner (M, Name), for any Name. 
Ocaps created by
one module can be made accessible to other modules, who can then claim ownership.
This allows an ocap to have multiple owners, so long as ownership was
explicitly granted by an existing owner. For instance, if M created an ocap O called "jogor",
then O will have owner (M, "jogor"). If M makes O available to another module
M2, then M2 can claim ownership of O using the name "yogurt". Now O has two
owners, (M, "jogor") and (M2, "yogurt").

The ocaps themselves are Go pointers. Since these are non-deterministic on each
machine and are non-forgeable, they are not persisted in any store and thus do not persist across process restarts.
In order to identify ocaps and their owners during startup, each ocap is assigned a unique index from 
a global, incrementing index variable, and a mapping from index to owners is persisted in the
store. This allows the set of ocaps and their owners to be recomputed when a
process restarts.

See also the description in the
[docs](https://docs.cosmos.network/master/modules/capability/).

### function NewCapability(ctx, name)

called by a module M.
global index is I.

- preconditions:
    - there does not exist a capability with owner (M, name)

- postcondition:
    - if preconditions are not satisfied, abort
    - a new capability O is returned with O.Index = I 
    - (M, name) is added as an owner of I in the persistent store
    - global index is incremented to I+1 in the persistent store
    - (M, O) is mapped to name in the memory store ("Fwd")
    - (M, name) is mapped to index in the memory store ("Rev")
      store
    - I is mapped to O in memory

### function AuthenticateCapability(ctx, cap, name)

called by a module M.
returns true iff (M, O) is mapped to name in the memory store.

### function ClaimCapability(ctx, cap, name)

called by a module M.

- preconditions:
    - (M, name) is not an owner of cap.Index

- postconditions:
    - if preconditions are not satisfied, abort
    - (M, name) is added as an owner of cap.Index in the persistent store
    - (M, cap) is mapped to name in the memory store
    - (M, name) is mapped to cap.Index in the memory store

### function ReleaseCapability(ctx, cap)

called by a module M.

- preconditions:
    - (M, cap) is mapped to some Name in the memory store

- postconditions:
    - mapping from (M, cap) to Name is removed from the memory store
    - mapping from (M, Name) to cap.Index is removed from the the memory store
    - (M, Name) is removed as an owner of cap.Index in the persistent store
    - if cap.Index has no more owners:
        - cap.Index is removed from the persistent store 
        - mapping from cap.Index to cap is removed from memory
