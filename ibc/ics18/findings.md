# ICS 18

## raw comments

- "Datagrams can be submitted individually as single transactions or
  atomically as a single transaction" writeup could be improved

- [ ] why are
  [Packets](https://github.com/cosmos/ics/tree/master/spec/ics-018-relayer-algorithms#packets-acknowledgements-timeouts)
  discussed here? But connection and channel and clientstate datagrams
  are not discussed? (I like the focus on the "normal" operation which
  is represented by packets, but it should be said that this is just
  normal operation)
   
- [ ] function pendingDatagrams:
    - update chain A to most recent header of chain B
    - update chain B to most recent header of chain A
    - advance all connection handshakes according to diagram in ICS02
      (do nothing if in final state)
    - advance all channel handshakes according to diagram in ICS03 (do nothing if in final state)
	- send packets
	- send acknowledgements
	- (although mentioned in a comment, no timeouts are handled in the
      current pseudo code)
	
- [ ] It is not clear why `pendingDatagrams` transmits all data, and
  doesn't miss some blocks.
	
- [ ] ["There are implicit ordering
  constraints"](https://github.com/cosmos/ics/tree/master/spec/ics-018-relayer-algorithms#ordering-constraints). These
  constraints need to be made explicit.
  
- [ ] ["Race
  conditions"](https://github.com/cosmos/ics/tree/master/spec/ics-018-relayer-algorithms#race-conditions):
  "if two relayers do so, the first transaction will succeed and the
  second will fail." only if both satisfy the "implicit" ordering
  constraint that the header need to be installed first. It might be
  that the first fails, then the header is installed, then the second
  succeeds.
  

