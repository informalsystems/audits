# ICS 03

## Spec does not match code


- the code does not check if connection IDs are valid identifiers (something that in 
the spec is a cause to abort a transaction)
-  `addConnectionToClient` in spec does not perform error handling, while in the code 
the transaction is aborted if the client does not exist.
- in the code of `ConnOpenTry`, but not in the spec:
    - the client parameters are validated (by calling `ValidateSelfClient`)
    - getting a consensus state from a given height aborts on error 
    - there is error handling when picking a version
    - the client state is verified, in addition to the client consensus state
- the function `PickVersion` in the code does the intersection between two version lists, 
while in the spec the intersection is done separately, and the intersection is passed as 
input to `PickVersion`
- in the code of `ConnOpenAck`, but not in the spec:
    - there is handling when getting the connection end by ID from the provable store
    - the client parameters are validated (by calling `ValidateSelfClient`)
    - getting a consensus state from a given height aborts on error 
    - the client state is verified, in addition to the client consensus state
    



## Code

- when the connection end is in `INIT`, the version list stored in the connection end is either 
a list of a single element or a list of all compatible versions. 
The `ConnOpenAck` datagram has a `version` field, so when handling `ConnOpenAck` in the case 
when the connection end is in `INIT`, the code only checks if the `version` field from the datagram 
is in the list of compatible versions, not if it is in the list of a single element (possibly) stored  
in the connection end ([here](https://github.com/cosmos/cosmos-sdk/blob/master/x/ibc/core/03-connection/keeper/handshake.go#L227)).

## To be discussed
  
- in the spec the version stored in a connection end is sometimes a list, and sometimes a single version. 
Maybe it should always be a list, and when the version is picked, 
it should be a list of length 1 (this is done in the code).