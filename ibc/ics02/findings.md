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

## Important to look at

- checkValidityAndUpdateState
