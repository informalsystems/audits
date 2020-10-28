# ICS20 Findings

 birthday attack on escrow address if port+channel id are same as pubkey


newAddress is not defined and neither are its invariants
- should be deterministic function of port and channel ?


packet handling ordering is reversed in some cases (handler before module, but acknowledgement corresponds to spec)

how can we check account balances are correct in invariants in transfer module ... it doesnt have access to accounts ...

createOutgoingPacket spec has extra redundant source argument


ensure slashes and "ibc" are not allowed in coin denoms ...

denom hashing isnt mentioned at all in the spec


what happens to channel when client expires?

