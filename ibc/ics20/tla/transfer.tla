-------------------------- MODULE transfer ----------------------------
(**
 * A primitive model for account arithmetics and token movement 
 * of the Cosmos SDK ICS20 Token Transfer
 * We completely abstract away many details, 
 * and want to focus on a minimal spec useful for testing  
 *) 


EXTENDS Integers, FiniteSets, Sequences, identifiers, denom, account_record


CONSTANT
  MaxAmount


\* INSTANCE denom_record \* WITH Identifiers <- Identifiers, NullId <- NullId, Denoms <- Denoms

VARIABLE
  error,
  bank,
  p,  \* we want to start with generating single packets 
  history,
  count

(*
Denoms == GenSeq(MaxDenomLength)
Accounts == GenSeq(MaxAccountLength)


*)

a <: b == a

Amounts == 0..MaxAmount


(**
   Abstraction of denomination traces
   
   We want to abstract from a concrete representation of denomination traces as sequences
   into a datatype with prefix/suffix operations for construction/deconstruction of traces.
   
   The interface consists of: 
    - MakeDenomTrace(port, channel, denom)
    - GetPort(trace)
    - GetChannel(trace)
    - GetDenom(trace)
*)

(*
AccountTraces == [
  port: Identifiers,
  channel: Identifiers,
  account: Accounts
]


GetEscrowAccount(port, channel) == [
  port |-> port,
  channel |-> channel,
  account |-> NullId
]

GetAccount(account) == [
  port |-> NullId,
  channel |-> NullId,
  account |-> account
]

NullAccount == [
  port |-> NullId,
  channel |-> NullId,
  account |-> NullId
]

*)

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

(*
IsSource(packet) ==
  packet.data.denom[1] = packet.sourcePort /\ packet.data.denom[2] = packet.sourceChannel
*)

IsSource(packet) ==
  /\ GetPort(packet.data.denomTrace) = packet.sourcePort
  /\ GetChannel(packet.data.denomTrace) = packet.sourceChannel


WellFormedPacket(packet) ==
  /\ packet.sourcePort /= NullId
  /\ packet.sourceChannel /= NullId
  /\ packet.destPort /= NullId
  /\ packet.destChannel /= NullId
  /\ packet.data.amount > 0
  /\ \/ GetPort(packet.data.denomTrace) = NullId /\ GetChannel(packet.data.denomTrace) = NullId
     \/ IsSource(packet)


OnRecvPacketPre(packet) ==
  LET data == packet.data
      trace == data.denomTrace
      denom == GetDenom(trace)
      amount == data.amount
  IN
  \* /\ denom /= AsAddress(NativeDenom)
  /\ amount > 0
     \* what happens if there is no receiver account? 
  /\ data.receiver /= NullId
  /\ IsSource(packet) =>  
       LET escrow == GetSourceEscrowAccount(packet)
       IN  /\ <<escrow, data.denomTrace>> \in DOMAIN bank
           /\ bank[escrow, data.denomTrace] >= amount


BankWithAccount(abank, account, denom) ==
    IF <<account, denom>> \in DOMAIN abank 
    THEN abank
    ELSE [x \in DOMAIN bank \union { <<account, denom>> } 
          |-> IF x = <<account, denom>>
              THEN 0
              ELSE bank[x] ]

       
OnRecvPacketNext(packet) ==
   LET data == packet.data IN
   LET denom == GetDenom(data.denomTrace) IN
   LET amount == data.amount IN
   LET receiver == data.receiver IN
   IF OnRecvPacketPre(packet) 
   THEN 
        /\ error' = FALSE
        /\ IF IsSource(packet) 
           THEN 
                \* transfer from the escrow acount to the receiver account
                LET escrow == GetSourceEscrowAccount(packet) IN
                LET bankwithreceiver == BankWithAccount(bank, MakeAccount(receiver), data.denomTrace) IN            
                bank' = [bankwithreceiver
                    EXCEPT ![MakeAccount(receiver), data.denomTrace] = @ + amount,
                           ![escrow, data.denomTrace] = @ - amount]
           ELSE 
                \* create new tokens with new denomination and transfer it to the receiver account
                LET denomTrace == MakeDenomTrace(packet.destPort, packet.destChannel, denom) IN
                LET bankwithreceiver ==
                    BankWithAccount(bank, MakeAccount(receiver), denomTrace) IN   
                bank' = [bankwithreceiver
                    EXCEPT ![MakeAccount(receiver),denomTrace] = @ + amount]
   ELSE 
       /\ error' = TRUE
       /\ UNCHANGED bank

(*
              
\* the input is not a packet, but a packet can be generated from the input parameters        
createOutgoingPacketPre(packet) ==
   LET data == packet.data IN
   LET denom == data.denom IN
   LET sender == data.sender IN
   LET amount == data.amount IN
   LET escrow == GetSourceEscrowAccount(packet) IN
   /\ \/ denom = AsAddress(NativeDenom)
      \/ /\ denom[1] = packet.sourcePort
         /\ denom[2] = packet.sourceChannel
   /\ amount > 0
   /\ data.sender /= AsAddress(<<NullId>>)
   /\ <<escrow, denom>> \in DOMAIN bank  
   /\ <<sender, denom>> \in DOMAIN bank
   /\ bank[sender, denom] >= amount
       
        
\* we don't actually send a packet but just update the accounts        
createOutgoingPacketNext(packet) ==
   LET data == packet.data IN
   LET denom == data.denom IN
   LET amount == data.amount IN
   LET sender == data.sender IN
   LET escrow == GetSourceEscrowAccount(packet) IN
   IF createOutgoingPacketPre(packet)
   THEN
        /\ error' = FALSE
        /\ IF IsSource(packet) 
           THEN 
                \* tokens are from other chain. We forward them.
                \* burn sender's money
                bank' = [bank EXCEPT ![sender, denom] = @ - amount]
           ELSE 
                \* tokens are from this chain
                \* transfer tokens from sender into escrow account
                bank' = [bank EXCEPT ![sender, denom] = @ - amount,
                                     ![escrow, denom] = @ + amount]
   ELSE
       /\ error' = TRUE
       /\ UNCHANGED bank

*)


Init == 
  \* /\ bank \in [(AccountTraces \X DenomTraces) -> Amounts]
  /\ p \in Packets
  /\ bank = [ x \in {<<NullAccount, NullDenomTrace>>} |-> 0  ]
  /\ count = 0
  /\ history = [
       n \in {0} |-> [
          error |-> FALSE,
          packet |-> p
       ]
     ]
  /\ error = FALSE
  
Next ==
  /\ p' \in Packets
  /\ count'= count + 1
  /\ OnRecvPacketNext(p)
  /\ history' = [ n \in DOMAIN history \union {count'} |->
       IF n = count' THEN
         [ error |-> error', packet |-> p' ]
       ELSE history[n]
     ]
  
Inv == 
  \* /\ WellFormedPacket(p)
  \* /\ Cardinality(DOMAIN bank) < 2
  /\ count < 3


=============================================================================
\* Modification History
\* Last modified Thu Nov 05 14:27:09 CET 2020 by andrey
\* Last modified Fri Oct 30 21:52:38 CET 2020 by widder
\* Created Thu Oct 29 20:45:55 CET 2020 by andrey
