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

UNROLL_DEFAULT_GenSeq == <<>> <: Seq(Int)
UNROLL_TIMES_GenSeq == 2

\* This produces denomination sequences up to the given bound
RECURSIVE GenSeq(_)
GenSeq(n) ==
  IF n = 0 THEN { <<>> }
  ELSE LET Shorter == GenSeq(n-1) IN
    { Append(s,x): x \in Identifiers, s \in Shorter } \union Shorter 

Denoms == GenSeq(MaxDenomLength)
Accounts == GenSeq(MaxAccountLength)

Amounts == 0..MaxAmount

GetEscrowAccount(portId, channelId) == <<portId, channelId>>

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
  /\ packet.sourcePort /= NullId
  /\ packet.sourceChannel /= NullId
  /\ packet.destPort /= NullId
  /\ packet.destChannel /= NullId
  /\ \A i \in DOMAIN packet.data.denom:
        packet.data.denom[i] /= NullId
  /\ packet.data.amount > 0
  /\ Len(packet.data.denom) % 2 = 1 
  /\ Len(packet.data.denom) > 1 => IsSource(packet)


OnRecvPacketPre(packet) ==
  LET data == packet.data
      denom == data.denom
      amount == data.amount
  IN
  /\ denom /= NativeDenom
  /\ amount > 0
     \* what happens if there is no receiver account? 
  /\ data.receiver /= NullId
  /\ IsSource(packet) =>  
       LET escrow == GetEscrowAccount(packet.sourcePort, packet.sourceChannel) 
       IN  /\ <<escrow, denom>> \in DOMAIN bank
           /\ bank[escrow, denom] >= amount


BankWithAccount(abank, account, denom) ==
    IF <<account, denom>> \in DOMAIN abank 
    THEN abank
    ELSE [x \in DOMAIN bank \union {<<account, denom>>} 
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
           \* transfer from the escrow acount to the receiver account
           THEN LET denomsuffix == SubSeq(denom, 3, Len(denom)) IN
                LET escrow == GetEscrowAccount(packet.sourcePort, packet.sourceChannel) IN
                LET bankwithreceiver == BankWithAccount(bank, receiver, denomsuffix) IN            
                bank' = [bankwithreceiver EXCEPT ![receiver, denomsuffix] = @ + amount, ![escrow, denom] = @ - amount]
            \* create new tokens with new denomination and transfer it to the receiver account
           ELSE LET prefixedDenomination == <<packet.destPort, packet.destChannel>> \o denom IN
                LET bankwithreceiver == BankWithAccount(bank, receiver, prefixedDenomination) IN   
                bank' = [bankwithreceiver EXCEPT ![receiver,prefixedDenomination] = @ + amount]
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
   /\ \/ denom = NativeDenom
      \/ /\ denom[1] = packet.sourcePort
         /\ denom[2] = packet.sourceChannel
   /\ amount > 0
   /\ data.sender /= NullId
   /\ <<escrow, denom>> \in DOMAIN bank  
   /\ <<sender, denom>> \in DOMAIN bank
   /\ bank[sender, denom] >= amount
\* Josef made up the following
   /\ IsSource(packet) => bank[escrow, denom] >= amount
        
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
                \* burn vouchers in escrow account
                bank' = [bank EXCEPT ![escrow, denom] = @ - amount]
           ELSE 
                \* tokens are from this chain
                \* transfer tokens from sender into escrow account
                bank' = [bank EXCEPT ![sender, denom] = @ - amount, ![escrow, denom] = @ + amount]
   ELSE
       /\ error' = TRUE
       /\ UNCHANGED bank

Init == 
  /\ \E fun \in [ 1..NInitBankAccounts -> (Accounts \X Denoms) ]:
      bank \in [{fun[i]: i \in DOMAIN fun} -> Amounts]
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
\* Last modified Fri Oct 30 21:39:07 CET 2020 by widder
\* Last modified Fri Oct 30 16:39:38 CET 2020 by andrey
\* Created Thu Oct 29 20:45:55 CET 2020 by andrey


\* Leftovers from some initial experiments; please ignore

VARIABLE
  chains

Balances == 0 .. MaxBalance

Map(keyset, values) == 
  \E keys \in SUBSET keyset:
  \E map \in [keys -> values]:
  map


Addresses == [ 
  chain |-> Chains,
  account |-> Accounts
]


Wallets == [ SUBSET Denoms -> Balances ]

Accounts == [ SUBSET Addresses -> Wallets ]

Init == 
  chains = 
  \E chain_accounts \in [Chains -> Accounts]:
   chains = chain_accounts
  
Next == 
  chains' = chains

Inv == 
     \A c \in Chains:
       Cardinality(DOMAIN chains[c]) = 2

Inv1 == 
     \A c \in Chains:
     \A a \in Addresses:
     \A d \in Denoms:
       chains[c][a][d] < 3


Coins == [
  denom: Denoms,
  amount: Int
]


CONSTANT
  Chains,
  Accounts,
  Denoms,
  MaxBalance

VARIABLE
  chains

Balances == 0 .. MaxBalance

Wallets == [ SUBSET Denoms -> Balances ]




TypeOK == 
  banks \in [ Chains -> 

Init == 
  \E chain_accounts \in [Chains -> Accounts]:
   banks = [c \in Chains |-> 
   chains = chain_accounts
  
Next == 
  chains' = chains


Inv == 
     \A c \in Chains:
       Cardinality(DOMAIN chains[c]) = 2


Inv1 == 
     \A c \in Chains:
     \A a \in Addresses:
     \A d \in Denoms:
       chains[c][a][d] < 3


CONSTANT
  Chains,
  Addresses,
  Denoms,
  MaxBalance

VARIABLE
  chains

Balances == 0 .. MaxBalance

Wallets == [ Denoms -> Balances ]

Accounts == [ Addresses -> Wallets ]

Init == 
  \E chain_accounts \in [Chains -> Accounts]:
   chains = chain_accounts
  
Next == 
  chains' = chains


Inv == 
     \A c \in Chains:
       Cardinality(DOMAIN chains[c]) = 2


Inv1 == 
     \A c \in Chains:
     \A a \in Addresses:
     \A d \in Denoms:
       chains[c][a][d] < 3



Accounts == [
  Addresses -> [ Denoms -> Balances ]
]

Init ==
  /\ \A c \in Chains:
     \E as \in [Chains -> SUBSET Addresses]:
     \E ds \in [SUBSET Denoms:
     \E bs \in [ ds -> Balances ]:
        chains[c] = [ c \in Chains |-> 
          [ a \in as |-> bs]
        ]
          
        
\*  /\ chains = [ c \in Chains |-> Accounts ]
        
Next == UNCHANGED <<chains>>


Inv == 
  \A c \in Chains:
  \A a \in DOMAIN chains[c]:
     \A d \in Denoms:
       chains[c][a][d] > 0
   


