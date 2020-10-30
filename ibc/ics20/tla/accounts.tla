-------------------------- MODULE accounts ----------------------------
(**
 * A primitive model of account arithmetics for ICS20 Token Transfer
 * We completely abstract away such details as channels
 *) 

EXTENDS Integers, FiniteSets


CONSTANT
  Chains,
  Addresses,
  Denoms,
  MaxBalance

VARIABLE
  chains

Balances == 0 .. MaxBalance

Wallets == [ SUBSET Denoms -> Balances ]

Accounts == [ SUBSET Addresses -> Wallets ]

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


=============================================================================
\* Modification History
\* Last modified Fri Oct 30 11:00:56 CET 2020 by andrey
\* Created Thu Oct 29 20:45:55 CET 2020 by andrey


CONSTANT
  Chains,
  Accounts,
  Denoms,
  MaxBalance

VARIABLE
  chains

Balances == 0 .. MaxBalance

Wallets == [ SUBSET Denoms -> Balances ]

Addresses == [ 
  chain |-> Chains,
  account |-> Accounts
]



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


Coins == [
  denom: Denoms,
  amount: Int
]


FungibleTokenPackets == [
  sender: Addresses,
  receiver: Addresses,
  denom: Denoms,
  amount: Int
]


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
   

OnRecvPacket(srcChain, dstChain, packet) ==
  packet.amount > 0
