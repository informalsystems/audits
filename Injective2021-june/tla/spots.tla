------------------------------------ MODULE spots -----------------------------
EXTENDS Integers, Sequences, typedefs

CONSTANTS
    \* accounts in the system
    \* @type: Set(ACCOUNT);
    ACCOUNTS,
    \* available coin types
    \* @type: Set(COIN);
    COINS,
    \* potential markets
    \* @type: Set(<<COIN, COIN>>);
    MARKETS

\* 18 places are reserved for the digits after "."
PRECISION == 10^18

VARIABLES
    \* cosmos account balances
    \* @type: <<ACCOUNT, COIN>> -> Int;
    balances,
    \* available deposits on subaccounts
    \* @type: <<ACCOUNT, COIN>> -> Int;
    available,
    \* total deposits on subaccounts
    \* @type: <<ACCOUNT, COIN>> -> Int;
    total,
    \* available markets
    \* @type: Set(MARKET);
    running_markets,
    \* whether there was a failing transaction
    \* @type: Bool;
    tx_fail,
    \* the last executed tx
    \* @type: TX;
    tx

Init ==
    /\ tx = [ type |-> "init", fail |-> FALSE ]
    \* these are the balances in setup-informal.sh, which we can change later
    /\ balances = [ a \in ACCOUNTS, c \in COINS |->
          IF a = "user1" \/ c = "inj"
          THEN \* 1000000000000000000000.000000000000000000
                1000000000000000000000000000000000000000
          ELSE 0
       ]
    /\ available = [ a \in ACCOUNTS, c \in COINS |-> 0 ]
    /\ total = [ a \in ACCOUNTS, c \in COINS |-> 0 ]
    /\ running_markets = {}
    /\ tx_fail = FALSE

Deposit(a, c) ==
    \E quantity \in Int:
        LET fail == \/ balances[a, c] < quantity
                    \/ quantity < PRECISION
                    \/ quantity % PRECISION /= 0
        IN
        /\ balances' = [ balances EXCEPT ![a, c] = @ - quantity ]
        /\ available' = [ available EXCEPT ![a, c] = @ + quantity ]
        /\ total' = [ total EXCEPT ![a, c] = @ + quantity ]
        /\ tx' = [ type |-> "deposit",
                   fail |-> fail,
                   coin |-> c,
                   account |-> a,
                   quantity |-> quantity ]
        /\ tx_fail' = (fail \/ tx_fail)
        /\ UNCHANGED running_markets

Withdraw(a, c) ==
    \E quantity \in Int:
        LET fail == \/ available[a, c] < quantity
                    \/ quantity < PRECISION
                    \/ quantity % PRECISION /= 0
        IN
        /\ balances' = [ balances EXCEPT ![a, c] = @ + quantity ]
        /\ available' = [ available EXCEPT ![a, c] = @ - quantity ]
        /\ total' = [ total EXCEPT ![a, c] = @ - quantity ]
        /\ tx' = [ type |-> "withdraw",
                   fail |-> fail,
                   coin |-> c,
                   account |-> a,
                   quantity |-> quantity ]
        /\ tx_fail' = (fail \/ tx_fail)
        /\ UNCHANGED running_markets

LaunchSpotMarket(a, m) ==
    /\ m \notin running_markets
    /\ running_markets' = { m } \union running_markets
    /\ tx' = [ type |-> "instant-spot-market-launch",
               fail |-> FALSE,
               base |-> m[1],
               quote |-> m[2],
               account |-> a ]
    /\ UNCHANGED <<balances, available, total, tx_fail>>

DemolishSpotMarket(a, m) ==
    /\ m \in running_markets
    /\ running_markets' = running_markets \ {m}
    /\ tx' = [ type |-> "set-spot-market-status",
               fail |-> FALSE,
               base |-> m[1],
               quote |-> m[2],
               status |-> "Demolished",
               account |-> a ]
    /\ UNCHANGED <<balances, available, total, tx_fail>>

PayPlusFee(coins) ==
    \* we make sure that the user has enough coins to pay the taker fee
    (1002 * coins) \div 1000

\* @type: (Str, <<Str, Str>>) => Bool;
CreateSpotLimitOrderBuy(a, m) ==
    LET base == m[1]
        quote == m[2]
    IN
    \E quantity, price \in Int:
        LET quote_quantity == quantity * price
            ppf == PayPlusFee(quote_quantity)
            fail == \/ available[a, quote] < ppf
                    \/ quantity <= 0
                    \/ price <= 0
        IN
        /\ m \in running_markets
        /\ available' = [ available EXCEPT ![a, quote] = @ - ppf ]
        /\ tx' = [ type |-> "create-spot-limit-order",
                   fail |-> fail,
                   direction |-> "buy",
                   base |-> base,
                   quote |-> quote,
                   quantity |-> quantity,
                   price |-> price,
                   account |-> a
                 ]
        /\ tx_fail' = (fail \/ tx_fail)
        /\ UNCHANGED <<balances, running_markets, total>>

\* @type: (Str, <<Str, Str>>) => Bool;
CreateSpotLimitOrderSell(a, m) ==
    LET base == m[1]
        quote == m[2]
    IN
    \E quantity, price \in Int:
        LET fail == available[a, base] < quantity \/ quantity <= 0 \/ price <= 0 IN
        /\ m \in running_markets
        /\ available' = [ available EXCEPT ![a, base] = @ - quantity ]
        /\ tx' = [ type |-> "create-spot-limit-order",
                   fail |-> fail,
                   direction |-> "sell",
                   base |-> base,
                   quote |-> quote,
                   quantity |-> quantity,
                   price |-> price,
                   account |-> a
                 ]
        /\ tx_fail' = (fail \/ tx_fail)
        /\ UNCHANGED <<balances, running_markets, total>>

Next ==
    \/ \E a \in ACCOUNTS \ {"genesis"}, c \in COINS:
        \/ Deposit(a, c)
        \/ Withdraw(a, c)
    \/ \E m \in MARKETS:
        \/ LaunchSpotMarket("genesis", m)
        \/ DemolishSpotMarket("genesis", m)
    \/ \E a \in ACCOUNTS \ {"genesis"}, m \in MARKETS:
        \/ CreateSpotLimitOrderBuy(a, m)
        \/ CreateSpotLimitOrderSell(a, m)

\* restrict to non-failing actions only
NextNoFail ==
    Next /\ ~tx_fail'

===============================================================================
