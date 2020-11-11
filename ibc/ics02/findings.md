# ICS 002

- [ ] ICS002 (due to its number) serves as an entry point for
  newcomers who want to learn about IBC. I believe the current
  structure of the text does not serve that purpose well. I would
  suggest a reorganization, perhaps along the following ideas (if such
  a document already exists it should just be linked in ICS 002)
     * start with an example: 
	     - two applications A1 and A2 on two chains
           C1 and C2. 
		 - A1 sends a packet to A2. 
		 - What does the relayer have
           to do (submit packet, submit header), 
		 - how the packet reaches A2, how A2 verifies the packet via 
		   channel, connection, client, header. 
		 - explain that header of proof height must be there in order
           to verify.
	 * make explicit what function of a client face towards
	     - the relayer
		 - the connection
		 - other?
	 * More structure: right now "validity predicate", "Misbehaviour
       predicate", "Height", "ClientState", etc., all appear on the
       same level, and thus indicate the same importance and same
       quality. That is doesn't help the reader. Ad structure by e.g., sections
       highlighting
	     - verification facing towards local channels, connections
		 - functions for relayer to submit data (validity predicate,
             misbehavior predicate)
		 - functions for relayer to query information about the
             client 
	 * it is a long document. An outline ([like that
       one](https://github.com/tendermint/spec/blob/master/rust-spec/lightclient/verification/verification_001_published.md#outline))
       would be great.
	 * understand who is the expected audience. 
  
- [ ] The discussion of
  [Blockchain](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#blockchain)
  is unclear. My understanding is that the rest of the ICSs (except
  possible the relayer) deal with sequential code, while here
  necessarily we need to talk about distributed aspects, faults,
  etc. So the language of pseudo code hits its limits. As a result,
  because distributed aspects are not described, it
  is not clear how one aspect have have a "MUST NOT" and
  "Possible violation scenario".
  
  
- [ ] The code has several aspects that are not discussed in the
  specification.
     - [upgrade](https://github.com/cosmos/cosmos-sdk/blob/0bd46574f431d8281e71cad2f166973bb558f7c3/x/ibc/core/02-client/types/msgs.go#L15)
	 - [genesis](https://github.com/cosmos/cosmos-sdk/blob/master/x/ibc/core/02-client/genesis.go)
	 - [proposal](https://github.com/cosmos/cosmos-sdk/blob/master/x/ibc/core/02-client/keeper/proposal.go)

- [ ] In ICS 002 the [Height](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#height) is more abstract (just a linear order),
  while the [implementation](https://github.com/cosmos/cosmos-sdk/blob/master/x/ibc/core/02-client/types/height.go) encodes it as a pair of integers in
  lexicographical order 

- [ ] the use of
  [cmp](https://github.com/cosmos/cosmos-sdk/blob/0bd46574f431d8281e71cad2f166973bb558f7c3/x/ibc/core/02-client/types/height.go#L57)
  in the code seems quite intricate. The pseudo code in [ICS
  007](https://github.com/cosmos/ics/tree/master/spec/ics-007-tendermint-client#height)
  seems more clear.
  

## raw comments 

-
  [Motivation](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#motivation)
  is unreadable

-
  [Definitions](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#definitions)
  is unreadable. 
     - `CommitmentRoot` = AppState
	 - `ConsensusState` = LightBlock (header)
	 - `ClientState`= latest header + configuration parameters (e.g.,
       trusting period + frozenHeight
	   
- [What is the point of
  that?](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#consensus)
  
- [Blockchain
  unclear](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#blockchain)
      - "MUST NOT" ... "Possible violation scenario"
	  - "MUST" ... "Possible violation scenario"
	  - "The validity of the validity predicate is dependent"
        paragraph unclear
		
- [Required
  functions](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#required-functions)
  So here the client is used to verify the data. Verification depends
  on the other blockchain

- The structure of the document is super unclear: the following and
  more appear in a sequence and are totally different issues:
  
    - [requirements on the other
  blockchain](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#query-interface)
  
    - [local
      functions](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#on-chain-state-queries)
	  
	- suddenly "Client types SHOULD define the following standardised
      query functions in order to allow relayers" without header. This
      is the first time relayer is mentioned in the document.
	  
    - [proof
      construction](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#proof-construction)
	  
	  
	  
- ["If a client can no longer be
  updated"](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#update)
  the text mixes many layers (from trusting period to packets)

- ["If the client detects proof of misbehaviour, the client can be
alerted"](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#misbehaviour) ??
	  
## Important to look at

- checkValidityAndUpdateState
