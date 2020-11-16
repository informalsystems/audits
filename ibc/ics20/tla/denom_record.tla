-------------------------- MODULE denom_record ----------------------------

(**
   The most basic implementation of denomination traces that allows only one-step sequences
   Represented via records
*)

EXTENDS identifiers

CONSTANT
  Denoms

DenomTraces == [
  port: Identifiers,
  channel: Identifiers,
  denom: Denoms
]

MakeDenomTrace(port, channel, denom) == [
  port |-> port,
  channel |-> channel,
  denom |-> denom
]

GetPort(trace) == trace.port
GetChannel(trace) == trace.channel
GetDenom(trace) == trace.denom

IsNativeDenomTrace(trace) == GetPort(trace) = NullId /\ GetChannel(trace) = NullId /\ GetDenom(trace) /= NullId
IsPrefixedDenomTrace(trace) == GetPort(trace) /= NullId /\ GetChannel(trace) /= NullId /\ GetDenom(trace) /= NullId

NullDenomTrace == [
  port |-> NullId,
  channel |-> NullId,
  denom |-> NullId
] 


DENOM == INSTANCE denom
DenomTypeOK == DENOM!DenomTypeOK


=============================================================================
\* Modification History
\* Last modified Thu Nov 05 16:41:47 CET 2020 by andrey
\* Created Thu Nov 05 13:22:40 CET 2020 by andrey
