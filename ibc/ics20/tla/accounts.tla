-------------------------- MODULE accounts ----------------------------
(**
 * A primitive model for account arithmetics and token movement 
 * of the Cosmos SDK ICS20 Token Transfer
 * We completely abstract away many details, 
 * and want to focus on a minimal spec useful for testing  
 *) 

EXTENDS Integers, FiniteSets, Sequences


CONSTANT
  Identifiers,
  NullId,
  MaxAmount,
  MaxDenomLength,
  MaxAccountLength,
  NativeDenom,
  NInitBankAccounts

VARIABLE
  error,
  bank,
  p  \* we want to start with generating single packets 

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

Denoms == GenSeq(MaxDenomLength)
Accounts == GenSeq(MaxAccountLength)

Amounts == 0..MaxAmount

GetEscrowAccount(portId, channelId) == AsAddress(<<portId, channelId>>)

FungibleTokenPacketData == [
  sender: Accounts,
  receiver: Accounts,
  denom: Denoms,
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
  packet.data.denom[1] = packet.sourcePort /\ packet.data.denom[2] = packet.sourceChannel


WellFormedPacket(packet) ==
  /\ packet.sourcePort /= AsAddress(<<NullId>>)
  /\ packet.sourceChannel /= AsAddress(<<NullId>>)
  /\ packet.destPort /= AsAddress(<<NullId>>)
  /\ packet.destChannel /= AsAddress(<<NullId>>)
  /\ \A i \in DOMAIN packet.data.denom:
        packet.data.denom[i] /= AsAddress(<<NullId>>)
  /\ packet.data.amount > 0
  /\ Len(packet.data.denom) % 2 = 1 
  /\ Len(packet.data.denom) > 1 => IsSource(packet)


OnRecvPacketPre(packet) ==
  LET data == packet.data
      denom == data.denom
      amount == data.amount
  IN
  /\ denom /= AsAddress(NativeDenom)
  /\ amount > 0
     \* what happens if there is no receiver account? 
  /\ data.receiver /= AsAddress(<<NullId>>)
  /\ IsSource(packet) =>  
       LET escrow == GetEscrowAccount(packet.sourcePort, packet.sourceChannel) 
       IN  /\ <<escrow, denom>> \in DOMAIN bank
           /\ bank[escrow, denom] >= amount


BankWithAccount(abank, account, denom) ==
    IF <<account, denom>> \in DOMAIN abank 
    THEN abank
    ELSE [x \in DOMAIN bank \union { <<account, denom>> } 
          |-> IF x = <<account, denom>>
              THEN 0
              ELSE bank[x] ]

       
OnRecvPacketNext(packet) ==
   LET data == packet.data IN
   LET denom == data.denom IN
   LET amount == data.amount IN
   LET receiver == data.receiver IN
   IF OnRecvPacketPre(packet) 
   THEN 
        /\ error' = FALSE
        /\ IF IsSource(packet) 
           THEN 
                \* transfer from the escrow acount to the receiver account
                LET denomsuffix == SubSeq(denom, 3, Len(denom)) IN
                LET escrow == GetEscrowAccount(packet.sourcePort, packet.sourceChannel) IN
                LET bankwithreceiver == BankWithAccount(bank, receiver, denomsuffix) IN            
                bank' = [bankwithreceiver
                    EXCEPT ![receiver, denomsuffix] = @ + amount,
                           ![escrow, denom] = @ - amount]
           ELSE 
                \* create new tokens with new denomination and transfer it to the receiver account
                LET prefixedDenomination ==
                    <<packet.destPort, packet.destChannel>> \o denom IN
                LET bankwithreceiver ==
                    BankWithAccount(bank, receiver, prefixedDenomination) IN   
                bank' = [bankwithreceiver
                    EXCEPT ![receiver,prefixedDenomination] = @ + amount]
   ELSE 
       /\ error' = TRUE
       /\ UNCHANGED bank

              
\* the input is not a packet, but a packet can be generated from the input parameters        
createOutgoingPacketPre(packet) ==
   LET data == packet.data IN
   LET denom == data.denom IN
   LET sender == data.sender IN
   LET amount == data.amount IN
   LET escrow == GetEscrowAccount(packet.sourcePort, packet.sourceChannel) IN
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
   LET escrow == GetEscrowAccount(packet.sourcePort, packet.sourceChannel) IN
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


Init == 
  /\ bank \in [(Accounts \X Denoms) -> Amounts]
  \* use the following approach to scope the enumeration in TLC
  \*/\ \E fun \in [ 1..NInitBankAccounts -> (Accounts \X Denoms) ]:
  \*    bank \in [{fun[i]: i \in DOMAIN fun} -> Amounts]
  /\ p \in Packets
  /\ error = FALSE
  
Next ==
  /\ OnRecvPacketNext(p)
  /\ UNCHANGED <<p>> 

Inv == 
  \* /\ WellFormedPacket(p)
  \* /\ Cardinality(DOMAIN bank) < 2
  /\ error = FALSE


=============================================================================
\* Modification History
\* Last modified Tue Nov 03 11:21:48 CET 2020 by andrey
\* Last modified Fri Oct 30 21:52:38 CET 2020 by widder
\* Created Thu Oct 29 20:45:55 CET 2020 by andrey
