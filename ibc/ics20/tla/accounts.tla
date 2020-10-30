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
  MaxDenomLength


VARIABLE
  p  \* we want to start with generating single packets 


\* This produces denomination sequences up to the given bound
RECURSIVE ProduceDenom(_)
ProduceDenom(n) ==
  IF n = 0 THEN { <<>> }
  ELSE LET Shorter == ProduceDenom(n-1) IN
    { Append(s,x): x \in Identifiers, s \in Shorter } \union Shorter 

Denoms == ProduceDenom(MaxDenomLength)

Amounts == 0..MaxAmount

FungibleTokenPacketData == [
  sender: Identifiers,
  receiver: Identifiers,
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

WellFormedPacket(packet) ==
  /\ packet.sourcePort /= NullId
  /\ packet.sourceChannel /= NullId
  /\ packet.destPort /= NullId
  /\ packet.destChannel /= NullId
  /\ \A i \in DOMAIN packet.data.denom:
        packet.data.denom[i] /= NullId
  /\ packet.data.amount > 0
  /\ Len(packet.data.denom) % 2 = 1 
  /\ Len(packet.data.denom) > 1 => 
       packet.data.denom[1] = packet.sourcePort /\ packet.data.denom[2] = packet.sourceChannel


Init == 
  p \in Packets
  
Next ==
  UNCHANGED p 

Inv == ~WellFormedPacket(p)
  


=============================================================================
\* Modification History
\* Last modified Fri Oct 30 13:01:16 CET 2020 by andrey
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
   


