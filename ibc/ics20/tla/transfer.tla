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

a <: b == a

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
  /\ packet.data.amount > 0
  /\ \/ GetPort(packet.data.denomTrace) = NullId /\ GetChannel(packet.data.denomTrace) = NullId
     \/ IsSource(packet)


OnRecvPacketPre(packet) ==
  LET data == packet.data
      trace == data.denomTrace
      denom == GetDenom(trace)
      amount == data.amount
  IN
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


Init == 
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
\* Last modified Thu Nov 05 14:46:16 CET 2020 by andrey
\* Last modified Fri Oct 30 21:52:38 CET 2020 by widder
\* Created Thu Oct 29 20:45:55 CET 2020 by andrey
