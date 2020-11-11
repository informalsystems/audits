# ICS 18

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
  
## unfinished
