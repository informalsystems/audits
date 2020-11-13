-------------------------- MODULE xctx ----------------------------
(**
 * cross-chain transactions 
 *) 

EXTENDS Integers, FiniteSets, Sequences


CONSTANT
    Identifiers,
    AccountIds,
    NullId,
    MaxAmount,
    MaxDenomLength,
    MaxAccountLength,
    Chains,
    NativeDenom,
  \*  NInitBankAccounts,
    BigBang,
    InitialBank,
    AtMostOnce,
    AsChain

VARIABLE
  error,
  bank,
  pending,  \* we want to start with generating single packets 
  step,
  upcomingEvent

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
  sender: AccountIds,
  receiver: AccountIds,
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

Functions == { "snd", "rcv", "timeout", "ack" }

\* we might extend spec to have per-event semantics
IBCSemantics == {"at most once", "lossy", "light client attack"}

Events == [
    packet: Packets,
    function: Functions,
    chain : Chains
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


OnRecvPacketPre(chain, packet) ==
  LET data == packet.data
      denom == data.denom
      amount == data.amount
  IN
  /\ denom /= AsAddress(NativeDenom[chain])
  /\ amount > 0
     \* what happens if there is no receiver account? 
  /\ data.receiver /= AsAddress(<<NullId>>)
  /\ IsSource(packet) =>  
       LET escrow == GetEscrowAccount(packet.sourcePort, packet.sourceChannel) 
       IN  /\ <<chain, escrow, denom>> \in DOMAIN bank
           /\ bank[chain, escrow, denom] >= amount


BankWithAccount(abank, chain, account, denom) ==
    IF <<chain, account, denom>> \in DOMAIN abank 
    THEN abank
    ELSE [x \in DOMAIN bank \union { <<chain, account, denom>> } 
          |-> IF x = <<chain, account, denom>>
              THEN 0
              ELSE bank[x] ]

       
OnTimeoutPacketPre(chain, packet) ==  
  LET data == packet.data
      denom == data.denom
      amount == data.amount
  IN
  /\ denom /= AsAddress(NativeDenom[chain])
     \* what happens if there is no receiver account? 
  /\ data.sender /= AsAddress(<<NullId>>)
  /\ IsSource(packet) =>  
       LET escrow == GetEscrowAccount(packet.sourcePort, packet.sourceChannel) 
       IN  /\ <<chain, escrow, denom>> \in DOMAIN bank
           /\ bank[chain, escrow, denom] >= amount
 

OnTimeoutPacketNext(chain, packet) == 
   LET data == packet.data IN
   LET denom == data.denom IN
   LET amount == data.amount IN
   LET sender == data.sender IN
   UNCHANGED pending /\ 
   IF OnTimeoutPacketPre(chain, packet) 
   THEN  
        /\ error' = FALSE
        /\ IF IsSource(packet) 
            THEN 
            \* transfer from the escrow acount to the sender account
                LET denomsuffix == SubSeq(denom, 3, Len(denom)) IN
                LET escrow == GetEscrowAccount(packet.sourcePort, packet.sourceChannel) IN
                LET bankwithreceiver == BankWithAccount(bank, chain, sender, denomsuffix) IN            
                bank' = [bankwithreceiver
                    EXCEPT ![chain, sender, denomsuffix] = @ + amount,
                           ![chain, escrow, denom] = @ - amount]
            ELSE 
            \* mint back the money  TODO:check that onCreatePacket takes the return money into account
             bank' = [bank EXCEPT ![chain, sender, denom] = @ + amount]
   
   ELSE 
       /\ error' = TRUE
       /\ UNCHANGED bank

       
OnRecvPacketNext(chain, packet) ==
   LET data == packet.data IN
   LET denom == data.denom IN
   LET amount == data.amount IN
   LET receiver == data.receiver IN
   UNCHANGED pending /\ 
   IF OnRecvPacketPre(chain, packet) 
   THEN 
        /\ error' = FALSE
        /\ IF IsSource(packet) 
           THEN 
                \* transfer from the escrow acount to the receiver account
                LET denomsuffix == SubSeq(denom, 3, Len(denom)) IN
                LET escrow == GetEscrowAccount(packet.sourcePort, packet.sourceChannel) IN
                LET bankwithreceiver == BankWithAccount(bank, chain, receiver, denomsuffix) IN            
                bank' = [bankwithreceiver
                    EXCEPT ![chain, receiver, denomsuffix] = @ + amount,
                           ![chain, escrow, denom] = @ - amount]
           ELSE 
                \* create new tokens with new denomination and transfer it to the receiver account
                LET prefixedDenomination ==
                    <<packet.destPort, packet.destChannel>> \o denom IN
                LET bankwithreceiver ==
                    BankWithAccount(bank, chain, receiver, prefixedDenomination) IN   
                bank' = [bankwithreceiver
                    EXCEPT ![chain, receiver, prefixedDenomination] = @ + amount]
   ELSE 
       /\ error' = TRUE
       /\ UNCHANGED bank

              
\* the input is not a packet, but a packet can be generated from the input parameters        
createOutgoingPacketPre(chain, packet, pbank) ==
   LET data == packet.data IN
   LET denom == data.denom IN
   LET sender == data.sender IN
   LET amount == data.amount IN
   LET escrow == GetEscrowAccount(packet.sourcePort, packet.sourceChannel) IN
   /\ \/ denom = AsAddress(NativeDenom[chain])
      \/ /\ denom[1] = packet.sourcePort
         /\ denom[2] = packet.sourceChannel
   /\ amount > 0
   /\ data.sender /= AsAddress(<<NullId>>)
   /\ <<chain, escrow, denom>> \in DOMAIN pbank  
   /\ <<chain, sender, denom>> \in DOMAIN pbank
   /\ bank[chain, sender, denom] >= amount
       
onTimeOut(chain, packet) ==
    pending' = pending \union {[packet |-> packet, function |-> "timeout", chain |-> chain]}

onSuccess(chain, packet) ==
    LET rcvChain == AsChain[packet.destPort, packet.destChannel] IN 
    pending' = pending \union {[packet |-> packet, function |-> "rcv", chain |-> rcvChain]}

onScenarioLightClientAttack(chain, packet) ==
    LET rcvChain == AsChain[packet.destPort, packet.destChannel] IN 
    pending' = pending \union {[packet |-> packet, function |-> "rcv", chain |-> rcvChain]}
                       \union {[packet |-> packet, function |-> "timeout", chain |-> chain]}

onLoss(chain, packet) ==
    UNCHANGED pending

IBCsend(chain, packet) ==
    \* what do we do about duplication
      \/ onTimeOut(chain, packet)
      \/ onSuccess(chain, packet)
\*    \/ onScenarioLightClientAttack(chain, packet)
\*    \/ onLoss(chain, packet)

\* we don't actually send a packet but just update the accounts        
createOutgoingPacketNext(chain, packet) ==
   LET data == packet.data IN
   LET denom == data.denom IN
   LET amount == data.amount IN
   LET sender == data.sender IN
   LET escrow == GetEscrowAccount(packet.sourcePort, packet.sourceChannel) IN
   LET bankwithescrow == BankWithAccount(bank, chain, escrow, denom) IN 
   IF createOutgoingPacketPre(chain, packet,bankwithescrow)
   THEN
        /\ error' = FALSE
        /\ IBCsend(chain, packet)
        /\ IF ~IsSource(packet) 
           \* This is how the check is encoded in ICS20 and the implementation.
           \* The meaning is "IF denom = AsAddress(NativeDenom)" because of the following argument:
           \* observe that due to the disjunction in createOutgoingPacketPre(packet), we have
           \* ~IsSource(packet) /\ createOutgoingPacketPre(packet) => denom = AsAddress(NativeDenom)
           THEN 
                \* tokens are from this chain
                \* transfer tokens from sender into escrow account
                bank' = [bankwithescrow EXCEPT ![chain, sender, denom] = @ - amount,
                                     ![chain, escrow, denom] = @ + amount]
           ELSE 
                \* tokens are from other chain. We forward them.
                \* burn sender's money
                bank' = [bankwithescrow EXCEPT ![chain, sender, denom] = @ - amount]
  ELSE
       /\ error' = TRUE
       /\ UNCHANGED <<pending, bank>>


Init == 
  \* /\ bank \in [(Chains \X Accounts \X Denoms) -> Amounts]
  \* /\ bank \in [(Chains \X Accounts \X Denoms) -> Amounts]
  \* use the following approach to scope the enumeration in TLC
  \*/\ \E fun \in [ 1..NInitBankAccounts -> (Accounts \X Denoms) ]:
  \*    bank \in [{fun[i]: i \in DOMAIN fun} -> Amounts]
  /\ pending = {BigBang} \* here there real init should happen
  /\ error = FALSE
  /\ step = "execute"
  /\ bank = InitialBank
  /\ upcomingEvent = BigBang
  

OnSendNext ==
    /\ upcomingEvent.function = "snd"
    /\ createOutgoingPacketNext(upcomingEvent.chain, upcomingEvent.packet)

OnRecvNext ==
    /\ upcomingEvent.function = "rcv"
    /\ OnRecvPacketNext(upcomingEvent.chain, upcomingEvent.packet)
 
OnTimeoutNext ==
    /\ upcomingEvent.function = "timeout"
    /\ OnTimeoutPacketNext(upcomingEvent.chain, upcomingEvent.packet)
   
\* Igor explains me later how to write that nicely.
Next == 
        \/  step \in {"pick", "TERMINATED"} /\ pending = {} /\ step'= "TERMINATED" 
                    /\ UNCHANGED <<bank, error, upcomingEvent, pending >>
                    
        \/ step = "pick" /\  \E event \in pending :
            /\ upcomingEvent' = event
            /\  IF AtMostOnce THEN
                    pending' = pending \ {event} 
                ELSE
                    UNCHANGED pending
            /\ step' = "execute"
            /\ UNCHANGED <<bank, error >>
            
        \/ step = "execute" 
              /\ step' = "pick"
              /\ 
                 \/ OnSendNext /\ upcomingEvent' = upcomingEvent  
                 \/ OnRecvNext /\ upcomingEvent' = upcomingEvent  
                 \/ OnTimeoutNext /\ upcomingEvent' = upcomingEvent
                \* \/ OnAckNext /\ upcomingEvent' = upcomingEvent
       
 


 

Inv == 
  \* /\ WellFormedPacket(p)
  \* /\ Cardinality(DOMAIN bank) < 2
  /\ error = FALSE


=============================================================================
\* Modification History
\* Last modified Fri Nov 13 18:22:37 CET 2020 by c
\* Last modified Tue Nov 03 11:21:48 CET 2020 by andrey
\* Last modified Fri Oct 30 21:52:38 CET 2020 by widder
\* Created Thu Oct 29 20:45:55 CET 2020 by andrey
