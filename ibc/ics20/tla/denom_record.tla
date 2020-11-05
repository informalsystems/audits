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
GetDenom(trace) == [
  port |-> NullId,
  channel |-> NullId,
  denom |-> trace.denom
] 


NullDenomTrace == [
  port |-> NullId,
  channel |-> NullId,
  denom |-> NullId
] 


DENOM == INSTANCE denom
DenomTypeOK == DENOM!DenomTypeOK


=============================================================================
\* Modification History
\* Last modified Thu Nov 05 15:49:26 CET 2020 by andrey
\* Created Thu Nov 05 13:22:40 CET 2020 by andrey
