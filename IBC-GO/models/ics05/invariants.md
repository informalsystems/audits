# Invariants


## BindPort(ctx, portID string) Capability

MUST only be called during initialization

preconditions:
- portID is valid
- portID is not already bound

postconditions:
- if preconditions are not satisfied, panic
- new ocap `key` is created in state with owner {"ibc", portID}
- `key` is returned

## Authenticate(ctx, key Capability,  portID string) bool

preconditions:
- portID is valid

postconditions:
- if preconditions are not satisfied, panic
- return true if key with name portID is owned by this module 

## LookupModuleByPort(ctx, portID string) (string, Capability, error) 

preconditions:
- portID is bound
- portID is owned by at most the "ibc" module and one other module

postconditions:
- if preconditions are not satisfied, return error
- returns module `M` that owns the port where `M` != "ibc"
