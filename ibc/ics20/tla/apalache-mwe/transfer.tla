-------------------------- MODULE transfer ----------------------------
(**
 * A primitive model for account arithmetics and token movement 
 * of the Cosmos SDK ICS20 Token Transfer
 * We completely abstract away many details, 
 * and want to focus on a minimal spec useful for testing
 *
 * We also try to make the model modular in that it uses
 * denomination traces and accounts via abstract interfaces,
 * outlined in denom.tla and account.tla
 *) 


EXTENDS Integers, FiniteSets, Sequences, identifiers, denom_record, account_record


CONSTANT
  MaxAmount

VARIABLE
  error,
  bank,
  p,  \* we want to start with generating single packets
  history,
  count

Amounts == 0..MaxAmount

GetSourceEscrowAccount(packet) == MakeEscrowAccount(packet.sourcePort, packet.sourceChannel)

FungibleTokenPacketData == [
  sender: AccountIds,
  receiver: AccountIds,
  denomTrace: DenomTraces,
  amount: Amounts
]

Packets == [
  \* We abstract those packet fields away
  \* sequence: uint64
  \* timeoutHeight: Height
  \* timeoutTimestamp: uint64
  sourcePort: Identifiers,
  sourceChannel: Identifiers,
  destPort: Identifiers,
  destChannel: Identifiers,
  data: FungibleTokenPacketData
]

IsSource(packet) ==
  /\ GetPort(packet.data.denomTrace) = packet.sourcePort
  /\ GetChannel(packet.data.denomTrace) = packet.sourceChannel


WellFormedPacket(packet) ==
  /\ packet.sourcePort /= NullId
  /\ packet.sourceChannel /= NullId
  /\ packet.destPort /= NullId
  /\ packet.destChannel /= NullId
  /\ packet.data.amount > 0                               \* option 1: move this line to the end of OnRecvPacketPre(packet)
  /\ \/ IsNativeDenomTrace(packet.data.denomTrace)
     \/ IsSource(packet)

OnRecvPacketPre2(packet) == FALSE

OnRecvPacketPre(packet) ==
  LET data == packet.data IN                              \* option 2: remove this line
  /\ WellFormedPacket(packet)
  /\ GetDenom(packet.data.denomTrace) /= NullId

OnRecvPacketNext(packet) ==
   \/  /\ error' = FALSE
       /\ OnRecvPacketPre(packet)
       /\ UNCHANGED bank

   \/  /\ error' = TRUE
       /\ ~OnRecvPacketPre(packet)
       /\ UNCHANGED bank

Init ==
  /\ p \in Packets
  /\ bank = [ x \in {<<NullAccount, NullDenomTrace>>} |-> 0  ]
  /\ count = 0
  /\ history = [
       n \in {0} |-> [
          error |-> FALSE,
          packet |-> p,
          bankBefore |-> bank,
          bankAfter |-> bank
       ]
     ]
  /\ error = FALSE
  
Next ==
  /\ p' \in Packets
  /\ count'= count + 1
  /\ OnRecvPacketNext(p)
  /\ history' = [ n \in DOMAIN history \union {count'} |->
       IF n = count' THEN
         [ packet |-> p, error |-> error', bankBefore |-> bank, bankAfter |-> bank' ]
       ELSE history[n]
     ]
  
Inv == 
  \* /\ WellFormedPacket(p)
  \* /\ Cardinality(DOMAIN bank) < 2
  count /= 4 \* \/ error /= TRUE


=============================================================================
\* Modification History
\* Last modified Thu Nov 05 20:56:37 CET 2020 by andrey
\* Last modified Fri Oct 30 21:52:38 CET 2020 by widder
\* Created Thu Oct 29 20:45:55 CET 2020 by andrey
