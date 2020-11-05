-------------------------- MODULE denom_sequence ----------------------------

(**
   The implementation of denomination traces via sequences
*)

EXTENDS Integers, Sequences, identifiers

CONSTANT
  Denoms,
  MaxDenomLength


a <: b == a
AsAddress(seq) == seq <: Seq(STRING)

UNROLL_DEFAULT_GenSeq == { AsAddress(<< >>) }
UNROLL_TIMES_GenSeq == 2

\* This produces denomination sequences up to the given bound
RECURSIVE GenSeq(_)
GenSeq(n) ==
  IF n = 0 THEN { AsAddress(<< >>) }
  ELSE LET Shorter == GenSeq(n-1) IN
    { Append(s,x): x \in Identifiers, s \in Shorter } \union Shorter 

DenomTraces == GenSeq(MaxDenomLength)

MakeDenomTrace(port, channel, denom) == <<port, channel>> \o denom

GetPort(trace) == trace[1]
GetChannel(trace) == trace[2]
GetDenom(trace) == SubSeq(trace, 3, Len(trace))


NullDenomTrace == <<>>


DENOM == INSTANCE denom
DenomTypeOK == DENOM!DenomTypeOK


=============================================================================
\* Modification History
\* Last modified Thu Nov 05 14:57:42 CET 2020 by andrey
\* Created Thu Nov 05 13:22:40 CET 2020 by andrey
