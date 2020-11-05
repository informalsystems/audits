-------------------------- MODULE denom ----------------------------

(**
   The denomination traces interface; please ignore the definition bodies.
*)

EXTENDS identifiers

CONSTANT
  Denoms

\* A non-account 
NullDenomTrace == "NullDenomTrace"

\* All denomination traces 
DenomTraces == {NullDenomTrace}

\* Make a new denomination trace from the port/channel prefix and the basic denom
MakeDenomTrace(port, channel, denom) == NullDenomTrace

\* Get the denomination trace port
GetPort(trace) == NullId

\* Get the denomination trace port
GetChannel(trace) == NullId

\* Get the denomination trace basic denomination
GetDenom(trace) == NullId


DenomTypeOK == 
  /\ NullDenomTrace \in DenomTraces
  /\ \A p \in Identifiers, c \in Identifiers, d \in Denoms: 
        MakeDenomTrace(p, c, d) \in DenomTraces
  /\ \A t \in DenomTraces:
       /\ GetPort(t) \in Identifiers
       /\ GetChannel(t) \in Identifiers
       /\ GetDenom(t) \in Denoms
       
     


=============================================================================
\* Modification History
\* Last modified Thu Nov 05 14:44:34 CET 2020 by andrey
\* Created Thu Nov 05 13:22:40 CET 2020 by andrey
