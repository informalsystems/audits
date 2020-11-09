# ICS 004

## spec

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
