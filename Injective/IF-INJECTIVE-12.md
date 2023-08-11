### IF-INJECTIVE-12
## Recommendation for recovery in EndBlocker #301

**Status: Unresolved** (as of June 11, 2021)

**Severity**: High

**Type**: Distributed System Reliability and Fault Tolerance

**Difficulty**: High

Surfaced from Informal Systems IBC Audit of hash e39a091197a1d8178edbce863a88e0452aa3443d

The function `EndBlocker` in `abci.go` runs the core logic of the exchange module:

https://github.com/InjectiveLabs/injective-core/blob/3c78e3962dbf3aa51fd3c283528ce6e5c6ce7602/injective-chain/modules/exchange/abci.go#L19-L139

The code that is called in `EndBlocker` can potentially call `panic`. For instance, the code in `sdk.Dec` may panic on overflow. In contrast to IBC handlers, the code in `EndBlocker` does not recover from panic. Instead, the Tendermint consensus stops operating. It is easy to see the potential effect of panic in `EndBlocker` by adding an explicit call to `panic` in `EndBlocker`.

**Recommendation**

While we did not manage to find a set of transactions that would trigger panic in `EndBlocker` (e.g., by triggering an overflow in `Dec`), we recommend wrapping the code in `EndBlocker` with a recovery block. Given the complexity of the logic in `EndBlocker`, it is not clear to us, whether such a recovery would be easy to implement.
