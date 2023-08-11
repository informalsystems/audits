# Recommendations 

This section aggregates all the recommendations made during the audit. Short-term
recommendations address the immediate causes of issues. Long-term recommendations
pertain to the development process and long-term design goals.

## Short term


- **Separate application-level acknowledgement codes from low level infrastructure aborts** ([IF-IBC-01](./IF-IBC-01.md)).
  The easiest way to fix this issue would be aligning specification of ICS20 with the code.
  
- **Distinguish between valid and invalid counterparty semantics in all function definitions of ICS20** 
  ([IF-IBC-02](./IF-IBC-02.md)). A user not aware of the Byzantine semantics of `recvPacket` may not be aware of this,
  which hinders a proper risk assessment, and development of application-level counter measures. Not taking this into
  account opens an area of attack that may lead to substantial financial loss. Furthermore, in the discussion be 
  precise about what is meant when referring to actions on the counterparty.
  E.g., make clear what is meant by "sent" in "IBC packet sent on the corresponding channel end on the counterparty 
  chain".
  
- **Provide more precise properties in ICS04** ([IF-IBC-03](./IF-IBC-03.md)). Application developer may be lured into 
  the trap of assuming these wrong properties and building their application on
  top of it, which opens a wide range of exploitable attack scenarios. Also distinguish between properties 
  between two valid chains, and properties a valid chain can expect if the counterparty chain is invalid (Byzantine). 
  
- **Make explicit all the ordering constraints** ([IF-IBC-04](./IF-IBC-04.md)). The order in which datagrams are 
  submitted is crucial to ensure progress in IBC. An exhaustive representations of these
  constraints need to be made explicit in the relayer specification (ICS018). Otherwise, it might lead to the 
  incorrect relayer implementations that fail to ensure liveness, or 
  results in transaction fees being spent unnecessarily. Furthermore, the required behavior of the relayer for 
  timeout handling should be specified. 
  
- **Improve ICS020 specification to prevent token lost issue in the crossing hellos scenario**
  ([IF-IBC-06](./IF-IBC-06.md)). In `onChanOpenTry`, the escrow account should be created only if it does not exist, i.e.,
  a check should be added to create an escrow account only if `channelEscrowAddresses[channelIdentifier]`
  does not exist. 

- **Align the type of `FungibleTokenPacketData.Amount` in ICS020 specification and implementation**
  ([IF-IBC-07](./IF-IBC-07.md))

- **Correct wrong usage of unbonding period in the Tendermint client** ([IF-IBC-08](./IF-IBC-08.md)).
Document and specify the misbehavior treatment, and make explicit timing assumptions.
Change the code to
  ```go
  if currentTimestamp.Sub(consState.Timestamp) >= clientState.TrustingPeriod {
  ``` 
  instead of 
  ```go
  if currentTimestamp.Sub(consState.Timestamp) >= clientState.UnbondingPeriod {
  ```

- **Correct handshake liveness issue with crossing hellos in ICS03/ICS04** ([IF-IBC-11](./IF-IBC-11.md)) 
  Add a mechanism in both the specification, and the implementation
  to deal with mismatched parameters.

- **Document in the developer documentation the implicit assumption on error propagation up the stack**
  ([IF-IBC-12](./IF-IBC-12.md)). At the moment, there are only hints regarding this in the form similar to this paragraph 
  in the
  [OnRecvPacket](https://github.com/cosmos/cosmos-sdk/blob/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8/x/ibc/applications/transfer/keeper/relay.go#L273-L285).
  Such hints do not constitute enough developer guidance to avoid introducing severe bugs, especially for Cosmos SDK newcomers.

## Long term


- **Improve ICS 20 implementation to serve as a template for future IBC applications**
  ([IF-IBC-01](./IF-IBC-01.md)). As ICS 20 also will serve as a template for future IBC applications, a clearer 
  separation between application-level errors and infrastructure roll-backs (and panics) would be advantageous. 
  For that purpose we suggest a more robust implementation of token transfer that does not rely on the bank module 
  panicking.
    
- **Provide test cases that involve corner cases** ([IF-IBC-04](./IF-IBC-04.md)). What complicates the situation with 
  testing relayer is the fact that ordering constraints involve concurrency effects that should be
  mitigated (serialized) at the relayer. Such issues are typically hard to reproduce or debug. Relying on model-based
  testing ([IF-IBC-13](./IF-IBC-13.md)) could be useful in this context.

- **Major refactoring of ICS02 specification** ([IF-IBC-05](./IF-IBC-05.md)). ICS02 (due to its number) serves as 
  de facto entry point for newcomers who want to learn about IBC. The current
  structure of the text does not serve that purpose well. We suggest a major reorganization, perhaps along the following
  ideas in [IF-IBC-05](./IF-IBC-05.md).
  
- **Prevent malicious IBC app module to claim any port or channel capability** ([IF-IBC-09](./IF-IBC-09.md))
  Using `LookupModuleByPort/ByChannelKeeper` methods should be restricted from outside the module - whoever is 
  composing modules, presumably in `app.go`, should explicitly define which methods of a keeper each module gets. 
  Otherwise, a malicious IBC application module could add the `LookupModuleByPort` method to its expected
  `PortKeeper` interface, and then open channels on some other module's port. This would allow a malicious IBC module
  to grab the capability associated with any channel, and send/recv messages on another module's channel.

- **Prevent escrow address collisions in ICS20** ([IF-IBC-10](./IF-IBC-10.md)). In order to mitigate the address
  collision problems, several recommendations are made:
  (1) limit the pre-image space,
  (2) use slow hash function,
  (3) change the channel establishment protocols and/or
  (4) redesign the Cosmos address space.

- **Document non-atomicity assumptions of operations** ([IF-IBC-12](./IF-IBC-12.md)). Either make the SDK functions
  atomic or introduce a separate explicit step for handlers, say `CommitState`, that 
  the handler will need to call to write state changes to the store. Otherwise, non-atomicity of operations can lead
  to bugs.
  
- **Use model based testing on critical components, ICS20 and ICS04** ([IF-IBC-13](./IF-IBC-13.md)). We have demonstrated on
  the ICS20 example the benefits of model-based testing. The set of developed
  artifacts covers the efforts of creating a preliminary model and a set of model-based tests for
  ICS-20 token transfer. While our model-based tests for the token transfer module
  have been successfully merged into Cosmos-SDK (see the PR [Cosmos-SDK #8145](https://github.com/cosmos/cosmos-sdk/pull/8145)), 
  only a very limited number of tests are contained there. We recommend the Cosmos-SDK developers to master the 
  model-based testing methodology (see [IF-IBC-13](./IF-IBC-13.md) for a short description), and to extend their 
  test suite with more model-based tests. This should help both to reduce the testing efforts from the developers, and 
  to increase the coverage of complicated scenarios. 
  
 
