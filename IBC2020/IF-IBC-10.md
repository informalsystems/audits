
### IF-IBC-10
## ICS20 - Escrow address collisions

**Severity**: High  
**Type**: Protocol/Implementation bug  
**Difficulty**: Medium     
**Involved artifacts**: [applications/transfer/types/keys.go](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/types/keys.go#L40-L47), [applications/transfer/keeper/relay.go](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/keeper/relay.go)   
Issue: [Cosmos-SDK #7737](https://github.com/cosmos/cosmos-sdk/issues/7737)


### Description

[GetEscrowAddress()](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/types/keys.go#L40-L47) is the truncated to 20 bytes `SHA256(portID + channelID)`. There are three problems with this approach, which are outlined below, and discussed in depth in the [Cosmos-SDK issue #7737](https://github.com/cosmos/cosmos-sdk/issues/7737).

#### No domain separation between ports and channels

 Using string concatenation doesn't separate the domains for ports and channels. Thus, e.g. port/channel 
 combinations `("transfer", "channel")` and `("trans", "ferchannel")` will give the same escrow address, the 
 truncated `SHA256("transferchannel")`. This opens the road to exploits. An exploit is possible if some module with 
 the bank capability is able to choose both the port and the channel ids.

The problem is outlined in the [Cosmos-SDK #7737 comment](https://github.com/cosmos/cosmos-sdk/issues/7737#issuecomment-726780022).


#### Collisions between module account addresses

Escrow account addresses have arbitrary alphanumeric strings as pre-images of `SHA-256`, and the post-image size of 
160 bits. This combination of the small post-image size and the fast hash function makes the [Birthday attack](https://en.wikipedia.org/wiki/Birthday_attack) feasible, as the security is reduced to only 80 bits. This means that a collision between two different escrow account addresses can be found after approximately 2^80 guesses. A detailed [cost analysis to attack truncated SHA256](https://github.com/tendermint/tendermint/issues/1990) was already performed in 2018 in the context of Tendermint, and demonstrates that the attack is also feasible and rather cheap from the cost perspective; this analysis is no less relevant today as it was back then.

Finding a collision means that two different escrow accounts map to the same account address. This can lead to the funds 
being stolen from the escrow account; see the problem scenario below.

The problem of birthday attacks on module accounts is analyzed in [Cosmos-SDK #7737 comment](https://github.com/cosmos/cosmos-sdk/issues/7737#issuecomment-730723042).

#### Collisions between module and non-module account addresses

Public account addresses are constructed as the same truncated to 20 bytes `SHA-256` of the Ed25519 public key. While 
160 bits of security is enough to prevent collision attacks on specific public addresses, the security against the 
Birthday attack is again only 80 bits. Here we find ourselves in a half-Birthday mode, when one address is generated 
by fast `SHA-256`, and another by a relatively slow `Ed25519 PublicKey` computation. While this scenario is much safer, 
it still opens a number of possible attacks both on escrow and on public accounts; see the particular scenario below.


### Problem Scenarios

#### Collisions between module account addresses

Assume that on `ChainA` there is a collision between two escrow addresses 
for `Addr == AddressHash("transfer", "channel-ab") = AddressHash("transfer", "channel-am")`. The following scenario 
becomes then possible: 

* Sender `Alice` on `ChainA` sends the ICS 20 token transfer of 1000 `atom` over `channel-ab` to receiver `Bob` on `ChainB`.
*  As `atom` is a native denomination, in [SendTransfer()](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/keeper/relay.go#L111-L122) it gets escrowed and sent to the escrow address `Addr == AddressHash("transfer", "channel-ab")` The ICS 20 packet is sent to `ChainB`
* Mallory discovers the address collision, sets up the fake `ChainM`, creates a connection to `ChainA`, and 
  establishes a channel to the `transfer` module on `ChainA` such that the channel id on `ChainA` is `channel-am`, 
  and on `ChainM` side is `channel-ma`. 
* Mallory sends the ICS 20 packet from `Mallory` on `ChainM` to `Mallory` on `ChainA` of 1000 coins with the 
  denomination `transfer/channel-ma/atom`
* [OnRecvPacket()](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/keeper/relay.go#L214-L226) recognizes the packet as the funds that originally were transferred from `ChainA` to `ChainM` due to the constructed denomination. It removes the prefix, unescrows 1000 `atom` from  `Addr == AddressHash("transfer", "channel-am")`, and happily sends them to `Mallory` on `ChainA`. Unescrowing succeeds because of the address collision and enough funds with the proper denomination on that address.
* Mallory now has 1000 atoms stolen from the original escrow account `Addr == AddressHash("transfer", "channel-ab")`. 
  She demolishes `ChainM`, and liquidates the funds from `Mallory` on `ChainA`. The attack succeeds.

#### Collisions between module and non-module account addresses

Assume that on `ChainA` there is a collision between the escrow address for `("transfer", "channel-ab")` and the 
ordinary account address obtained from the private key `PrivM`, i.e. `Addr == AddressHash("transfer", "channel-ab") = AddressHash(PublicKey(PrivM))`. The following (trivial) scenario becomes then possible: 

* Sender `Alice` on `ChainA` sends the ICS 20 token transfer of 1000 `atom` over `channel-ab` to receiver `Bob` on `ChainB`.
*  As `atom` is a native denomination, in [SendTransfer()](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/keeper/relay.go#L111-L122) it gets escrowed and sent to the escrow address `Addr == AddressHash("transfer", "channel-ab")` The ICS 20 packet is sent to `ChainB`
* Mallory discovers the address collision, i.e. it finds the private key `PrivM`. 
* Mallory liquidates the funds from `Addr` without any problems, as she posesses the private key for that address. The 
  attack succeeds.


### Recommendation

The problem of missing domain separation between ports and channels was already addressed in [Cosmos-SDK PR #7960](https://github.com/cosmos/cosmos-sdk/pull/7960).

We propose four different approaches to mitigate the address collision problems:

#### Approach 1: limit the pre-image space 

Do not allow unbounded or very large preimage spaces for module account addresses. Construct module account addresses not from arbitrary strings, but choose parameters from a small set of alternatives. E.g., in case of escrow addresses, the parameters for constructing an escrow address could be:

  * a prefix and a version number
  * fix PortId to "transfer"
  * deterministically construct ChannelId from e.g. a combination of the Ids of communicating chains and a bounded sequence number, e.g. 1-999. E.g. the escrow address could be `AddressHash("ibc-v1/transfer/cosmos-ethereum-001")`

For pre-image spaces up to approximately 32 bits it should be possible to prevent any kind of collisions completely, by enumerating all module account addresses and rejecting any attempt to register another account with the same address. 

#### Approach 2: use slow hash function

If limiting the pre-image space is undesirable from the design point of view, then excluding collisions completely becomes infeasible due to high resource consumption (both time and memory), but finding the collision for a dedicated attacker would be still feasible. In that case the alternative recommendation is as follows:
            
 * Change the hashing function from fast SHA-256 to some slow one, e.g. include `Ed25519 PublicKey` computation into the pre-image.
 * Perform collision search with limited memory for some limited amount of time -- this will provide some probabilistic guarantees of collision absence. 

#### Approach 3: change the channel establishment protocols

 Implement protocol-level measures to prevent free choice of addresses by a potential attacker. This is more long-term; the goal here is to guarantee the absence of collisions by changing the protocols. One such protocol-level measure could be to implement window-based selection of channel ids. E.g., when establishing a channel each party provides a window of local channel ids, (say [1-1000)), and the counterparty selects one id from that window. In that way the space of channel ids can be left unrestricted, but whenever a channel is established, provide a window that guarantees absence of collisions with any of existing escrow addresses: this will be easy and fast to do, because the windows will be in the order of e.g. bitwidth 10. At the same time, each party can prevent the other one from selecting a specific id, by choosing one from that window that guarantees absence of collisions also to the other party.
 
#### Approach 4: redesign the Cosmos address space

All of the above problems stem from the fact that a Cosmos address is a single binary piece of data only 20 bytes long. This was already raised before, see e.g. [Cosmos-SDK issue #3685](https://github.com/cosmos/cosmos-sdk/issues/3685). Architecturally cleanest, but also probably most difficult to implement, is to do the following:

 * Change the address format to allow multiple address kinds. That way escrow addresses will be a separate address kind, and no overlapping with the public addresses will be possible.
 * Extend the address length to 40 bytes, or simply make it (bounded) variable length. While 20 bytes are still enough at the present point, taking into account the speed of the parallelization and miniaturization happening now, moving from 20-byte addresses to at least 32-byte addresses is bound to happen in the next decade.
 
Concretely, the Cosmos address could look like that (with fields separated by e.g. a 0 byte, and Bech32-encoded): 

  1. variable-length address differentiator (e.g. public vs escrow).
  3. variable-length address data (e.g. `PublicKey` for public addresses, or `PortId/ChannelId` for escrow addresses).

This will bring the following advantages:

  * **Remove unneeded complexity**:
    * there will be no need to hash public keys, which are 32 or 33 bytes long, just store them as is.
    * e.g. for escrow addresses, do not hash, also store the port id and channel id directly.
  * **Allow unrestricted address flexibility**:
    * different key types -- no problem, just register different descriptors, like `secp256k1` or `secp256r1`.
    * group accounts, "organization" type entities, smart contracts, whatever else: request a new descriptor for it, and define the data.
    * one other possibility would be e.g. to have an IPv6 address + 20-byte old-style address to allow so to say "physical" addresses.
  * **Greatly increase security**:
    * no collisions between different address types is possible.
    * individual address security is increased to the maximum, e.g. to 32 bytes for Ed25519 addresses.
    * compromising one address type (e.g. the pre-image attack) will have no influence on other types.

It is important that this structure is in the  _address post-image_, not in the pre-image. This provides the separation of security between various address kinds.

The detailed discussion on changing the Cosmos address format can be found in the [Cosmos-SDK issue #5694](https://github.com/cosmos/cosmos-sdk/issues/5694)

#### Extended analysis for Approach 1: limit the pre-image space

While preparing this audit report, the Cosmos SDK development team has decided to follow the first of the proposed approaches, and limit the pre-image space for escrow addresses to 32 bits; this has been addressed by the [Cosmos SDK PR #7967](https://github.com/cosmos/cosmos-sdk/pull/7967). From our side, we have performed exhaustive search for escrow address collisions within this pre-image space, and have proven their absence. The details can be found in the [Cosmos-SDK #7737 comment](https://github.com/cosmos/cosmos-sdk/issues/7737#issuecomment-735671951).

