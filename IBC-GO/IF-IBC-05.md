
### IF-IBC-05
## ICS02 - Suggestions for restructuring

**Severity**: Informative  
**Type**: Specification restructuring proposal   
**Difficulty**: hard     
**Involved artifacts**: [ICS 02](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics)

### Description

ICS002 (due to its number) serves as de facto entry point for newcomers who want to learn about IBC. The current 
structure of the text does not serve that purpose well. We suggest a reorganization, perhaps along the following 
ideas (if such a document already exists it should just be linked in ICS 002).

### Problem Scenarios

N/A

### Recommendation

#### New entry point

Create a new entry point into IBC specification. In this new document:

* start with an example: 
	- two applications A1 and A2 on two chains C1 and C2. 
	- A1 sends a packet to A2. 
	- What does the relayer have to do (reading state, submit packet, submit header, timeouts), 
	- how the packet reaches A2, how A2 verifies the packet via 
		channel, connection, client, header. 
	- explain that header of proof height must be there in order
    to verify.

- This new document should also contain a discussion of the blockchain. The [current one](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#blockchain)
  is unclear. My understanding is that the rest of the ICSs (except the relayer) deal with sequential code, while here
  necessarily we need to talk about distributed aspects, faults,
  etc. So the language of pseudo code hits its limits. As a result, because distributed aspects are not described, it
  is not clear how one aspect can have a "MUST NOT" and q
  "Possible violation scenario" at the same time. 

- This would also be a good point to clarify the situation of counterparty chains. 
  - What are the precise assumptions? 
  - What is the good "normal" case? 
  - What is if the counterpart chain violates validity?
  - What is a light client attack?
  

#### Suggestions for ICS 02 (the client specification)

* Make explicit what function of a client face towards
	- the relayer
	- the connection
	- other?
* More structure: right now "validity predicate", "Misbehaviour
  predicate", "Height", "ClientState", etc., all appear on the
  same level, and thus indicate the same importance and same
  quality. That doesn't help the reader. Add structure by e.g., sections highlighting
	- verification facing towards local channels, connections
	- functions for relayer to submit data (validity predicate,
    misbehavior predicate)
	- functions for relayer to query information about the client 
	 
* Understand who is the expected audience (developers of IBC, developers of relayers, other?). What information are they looking for, how can we make it easy to find it.
  
* it is a long document. 
  An outline ([like that one](https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/verification/verification_001_published.md#outline))
  would be great.


