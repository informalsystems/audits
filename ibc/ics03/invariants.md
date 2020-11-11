# ICS 03

## ICS03 invariants

- If a connection end is in `INIT`, it can update its state either to `TRYOPEN` or `OPEN`
- If a connection end is in `TRYOPEN`, it can update its state to `OPEN`, and it cannot update its state to `INIT`
- If a connection end is in `OPEN`, it cannot update its state to `INIT` or to `TRYOPEN`
- A connection between two chains `ChainA` and `ChainB` is identified by a unique pair of connection identifiers 
`(ConnIDChainA, ConnIDChainB)`
- Once a connection between two chains is open, the connection ends on both chains have the same version
- The `clientID` and `connectionID` stored in the connection end at `ChainA` are equal to 
the `counterpartyClientID` and `counterpartyConnectionID` stored in the connection end at `ChainB` (and vice versa)

## ICS03 liveness
- It is always the case that if `ConnOpenInit` is handled on `ChainA`, then eventually the connection ends on 
both `ChainA` and `ChainB` are in state `OPEN`


### `function ConnOpenInit`

- preconditions:
    - `identifier` is a valid identifier,
    - there is no connection identified with `identifier` in the provable store,
    - `version` is either an empty string, or in the list of compatible versions, and
    - `identifier` can be added to the list of connections of the given client (i.e., 
    the client `clientIdentifier` exists).

- postconditions:      
    - the provable store contains a connection end, where:
        - its identifier is `identifier`, 
        - its state is `INIT`, 
        - the information about the counterparty is the one given as input, and 
        - the `versions` list is: 
            1. the list `[version]` consisting of the single version `version`, given as input, in case `version` is not an empty string, 
            2. the list of all compatible versions, otherwise 
    - the list of connections for the client contains the identifier `identifier`
    

### `function ConnOpenTry`

- preconditions:
    - `desiredIdentifier` is a valid identifier
    - `consensusHeight` (i.e., the height of the client for this chain on the counterparty chain) 
is smaller than the latest height of this chain,
    - `counterpartyChosenConnectionIdentifer` is either an empty string, or it is equal to `desiredIdentifier`,
    - either:
        - a connection identified by `desiredIdentifier` does not exist
        - or it is initialized with the same connection, client identifiers, and counterparty information
    - the intersection between the counterparty versions and the versions supported by the connection on this chain is not empty
    - the counterparty connection end state can be verified
    - the counterparty client consensus state can be verified  
    - `desiredIdentifier` can be added to the list of connections of the given client (i.e., 
    the client `clientIdentifier` exists).

- postconditions:        
    - the provable store contains a connection end, where:
        - its identifier is `desiredIdentifier`, 
        - its state is `TRYOPEN`, 
        - the information about the counterparty is the one given as input, and 
        - the `versions` list is the list `[version]` consisting of the single version `version`, picked from the intersection of the 
        versions supported by the counterparty and this chain
    - the list of connections for the client contains the identifier `desiredIdentifier`

### `function ConnOpenAck`

- preconditions:
    - `consensusHeight` (i.e., the height of the client for this chain on the counterparty chain) 
is smaller than the latest height of this chain,
    - the connection end identified by `identifier` exists in the provable store, 
    - the `counterpartyConnectionIdentifier` in the connection end is either an empty string, or equal to the `counterpartyIdentifier` from the `ConnOpenAck` datagram,
    - the connection end is either:
        - in state `INIT` and the `version` given as input is in the list of versions stored in the connection end, 
        - or in state `TRYOPEN` and the `version` given as input is equal to the version stored in the connection end,
    - the counterparty connection state can be verified,
    - the counterparty client state can be verified,  
    - the counterparty client consensus state can be verified.
    
- postconditions:        
    - the connection end identified by `identifier`:
        - has its state updated to `OPEN`,
        - has the version set to `version` (from the datagram),
        - has the `counterpartyConnectionIdentifier` set to `counterpartyConnectionID` (from the datagram).


### `function ConnOpenConfirm`

- preconditions:
    - the connection end identified by `identifier` exists in the provable store, 
    - the connection end is in state `TRYOPEN`
    - the counterparty connection state can be verified.
    
- postconditions:        
    - the connection end identified by `identifier` has its state updated to `OPEN`.
    