
### IF-IBC-09
## Malicious IBC app module can claim any port or channel capability using LookupModuleByPort/ByChannel

**Severity**: High    
**Type**: Implementation bug    
**Difficulty**: High    
**Involved artifacts**: 
[app.go](https://github.com/cosmos/cosmos-sdk/blob/82f15f3/simapp/app.go#L299), 
[/x/ibc/core/05-port/keeper/keeper.go](https://github.com/cosmos/cosmos-sdk/blob/82f15f3/x/ibc/core/05-port/keeper/keeper.go#L73), 
[x/ibc/core/04-channel/keeper/keeper.go](https://github.com/cosmos/cosmos-sdk/blob/82f15f3/x/ibc/core/04-channel/keeper/keeper.go#L406)

### Description

This is an instance of a more general class of issue with the SDK's object capability system, though it was here 
surfaced in the context of the IBC Port and Channel Keepers.

 In an ocap system, each ocap has associated with it a set of actions that can be performed, ie messages that can be 
 sent or methods that can be called. In the SDK, actions are defined through Keepers. Since all methods on a Keeper 
 are public, any module with access to a keeper can call all methods exposed by that keeper. In each module, we define 
 a `types/expected_keepers.go` which define the keepers this module uses (besides its own) as interfaces with a limited 
 set of methods. While useful for testing and local representation of the actions this module needs to execute, this 
 does not meaningfully restrict the ability of a malicious module to add other methods to its expected keepers 
 interfaces, and thus access other methods exposed by those keepers beyond those which are intended!

Of course this depends on malicious modules including code that escapes audit and review, which is maybe not an 
overwhelming concern right now, but the SDK has at least intended to mitigate such issues following principles of 
the least privilege via the ocap model. The problem is that keepers are actually granted to modules without 
minimizing privilege at all.

For instance, modules which receive the PortKeeper need only the PortKeeper.BindPort method:

```go
// PortKeeper defines the expected IBC port keeper
type PortKeeper interface {
	BindPort(ctx sdk.Context, portID string) *capabilitytypes.Capability
}
```

But a full `05-port/keeper/Keeper` is actually passed in, and the full keeper has a `LookupModuleByPort` method 
which returns the capability associated with a port. If this were exposed to IBC application modules, they'd 
all be able to claim capabilities for any other modules port, which would defeat the purpose of the port system.


### Problem Scenarios

A malicious IBC application module could add the `LookupModuleByPort` method to its expected PortKeeper interface, and 
then open channels on some other module's port. For instance the following diff to the `transfer` module should do it:

```diff
-// BindPort defines a wrapper function for the ort Keeper's function in
+// BindPort defines a wrapper function for the port Keeper's function in
 // order to expose it to module's InitGenesis function
 func (k Keeper) BindPort(ctx sdk.Context, portID string) error {
-       cap := k.portKeeper.BindPort(ctx, portID)
-       return k.ClaimCapability(ctx, cap, host.PortPath(portID))
+       someoneElsesPort := "transfer"
+       _, cap, _ := k.portKeeper.LookupModuleByPort(ctx, someoneElsesPort)
+       return k.ClaimCapability(ctx, cap, host.PortPath(someoneElsesPort))
 }

 // GetPort returns the portID for the transfer module. Used in ExportGenesis
diff --git a/x/ibc/applications/transfer/types/expected_keepers.go \
           b/x/ibc/applications/transfer/types/expected_keepers.go
index 284463350..5350c66bd 100644
--- a/x/ibc/applications/transfer/types/expected_keepers.go
+++ b/x/ibc/applications/transfer/types/expected_keepers.go
@@ -45,4 +45,5 @@ type ConnectionKeeper interface {
 // PortKeeper defines the expected IBC port keeper
 type PortKeeper interface {
        BindPort(ctx sdk.Context, portID string) *capabilitytypes.Capability
+       LookupModuleByPort(ctx sdk.Context, portID string) 
+          (string, *capabilitytypes.Capability, error)
 }
```

The same holds true for the `04-channel/keeper/Keeper` which exposes a `LookupModuleByChannel` method. Any IBC module 
could thus grab the capability associated with any channel, and send/recv on another modules channel.


### Recommendation

Keeper methods should be restricted from outside the module - whoever is composing modules, presumably in app.go, 
should explicitly define which methods of a keeper each module gets. Note this implies that expected keeper interfaces 
may end up duplicated (ie. once in the actual application for security and once in the module for local clarity/convenience), 
or may come to live in a trusted alternative place outside the control of an individual module. In any case, we may 
consider an external Secure interface for the expected keeper (from outside the module), and an 
insecure Local one (inside the module). So long as keeper variables inhabit a variable of the Secure type before being 
passed into modules, that should be sufficient. Ie.:

```go
/*
	Some keeper defined elsewhere with two methods. 
	We only want modules to access the Hi method
*/

type A struct{}

func (A) Hi()  {}
func (A) Bye() {}

/*
	Inside the Module
*/

// Malicious module tries to access the Bye method
type Local interface {
	Hi()
	Bye()
}

// Local function within the module
func LocalA(a Local) {}

/*
	Outside the Module
*/

// We only want modules to get the Hi method
type Secure interface {
	Hi()
}

func TestHelloWorld(t *testing.T) {

	// if we don't restrict a, the module can access all its methods
	a := A{}
	LocalA(a)

	// if we restrict a to the Secure interface, 
	// the module can't access other methods
	// and this fails to compile :)
	var a Secure = A{}
	LocalA(a)
}

```

### Related 

- [Cosmos-SDK #5931](https://github.com/cosmos/cosmos-sdk/issues/5931) points out an issue around module accounts being access by other modules. Even if module accounts were gated by ocaps, as that issue proposes, a general method which allowed those ocaps to be looked up (like we have in channel and port keepers) would still lead to compromise.
- [Cosmos-SDK #7093](https://github.com/cosmos/cosmos-sdk/issues/7093) points out various issues specific to the BankKeeper (ie. maintaining supply invariants), but also mentions that Keeper methods are not restricted before being passed into modules. So this issue is in some sense a duplicate of that issue, but specific for issues with Port and Channel Keeper.
