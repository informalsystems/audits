-------------------------- MODULE denom_record ----------------------------

(**
   The most basic implementation of denomination traces that allows only one-step sequences
   Represented via records
*)

EXTENDS identifiers

CONSTANT
  Denoms

Denom == INSTANCE denom

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


NullDenomTrace == [
  port |-> NullId,
  channel |-> NullId,
  denom |-> NullId
] 

DenomTypeOK == Denom!DenomTypeOK


=============================================================================
\* Modification History
\* Last modified Thu Nov 05 14:44:36 CET 2020 by andrey
\* Created Thu Nov 05 13:22:40 CET 2020 by andrey
