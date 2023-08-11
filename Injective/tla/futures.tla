------------------------------- MODULE futures -----------------------------
EXTENDS Integers, Sequences, typedefs_futures

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

\* the deposit that has to be put on a proposal
DEPOSIT == 10000000

\* the initial margin ratio when an order is placed, sync with atomkraft.py
INITIAL_MARGIN_RATIO == (5 * PRECISION) \div 100

\* the initial margin ratio when an order is placed, sync with atomkraft.py
MAINTENANCE_MARGIN_RATIO == (2 * PRECISION) \div 100

\* the fee in 'inj' for launching an instant market
LISTING_FEE == 1000000000000000000000

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
    \* status of a price feed
    \* @type: MARKET -> Str;
    active_feeds,
    \* market prices as reported by the price feed
    \* @type: MARKET -> Int;
    prices,
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
          IF a = "user1" /\ c = "atom"
          THEN 1000000000000000000000000
          ELSE IF c = "inj"
               THEN \* 1000.000000000000000000
                    1000000000000000000000
               ELSE 0
       ]
    /\ available = [ a \in ACCOUNTS, c \in COINS |-> 0 ]
    /\ total = [ a \in ACCOUNTS, c \in COINS |-> 0 ]
    /\ running_markets = {}
    /\ active_feeds = [ m \in MARKETS |-> "" ]
    /\ prices = [ m \in MARKETS |-> 0 ]
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
        /\ UNCHANGED <<running_markets, active_feeds, prices>>

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
        /\ UNCHANGED <<running_markets, active_feeds, prices>>

LaunchFuturesMarket(a, m) ==
    LET fail ==
        \/ m \in running_markets
        \/ active_feeds[m] = ""
        \/ balances[a, m[1]] < DEPOSIT
    IN
    /\ running_markets' = { m } \union running_markets
    /\ tx' = [ type |-> "expiryfuturesmarket-launch",
               fail |-> fail,
               base |-> m[1],
               quote |-> m[2],
               account |-> a ]
    /\ balances' = [ balances EXCEPT ![a, m[1]] = @ - DEPOSIT ]
    /\ tx_fail' = (fail \/ tx_fail)
    /\ UNCHANGED <<available, total, active_feeds, prices>>

LaunchInstantFuturesMarket(a, m) ==
    LET fail ==
        \/ m \in running_markets
        \/ active_feeds[m] = ""
        \/ prices[m] = 0
        \/ balances[a, "inj"] < LISTING_FEE
    IN
    /\ running_markets' = { m } \union running_markets
    /\ tx' = [ type |-> "instant-expiry-futures-market-launch",
               fail |-> fail,
               base |-> m[1],
               quote |-> m[2],
               account |-> a ]
    /\ balances' = [ balances EXCEPT ![a, "inj"] = @ - LISTING_FEE ]
    /\ tx_fail' = (fail \/ tx_fail)
    /\ UNCHANGED <<available, total, active_feeds, prices>>

GrantPriceFeeder(a, m) ==
    LET fail == active_feeds[m] /= "" \/ balances[a, "inj"] < DEPOSIT IN
    /\ tx' = [ type |-> "grant-price-feeder-privilege-proposal",
               fail |-> fail,
               base |-> m[1],
               quote |-> m[2],
               account |-> a ]
    /\ tx_fail' = (fail \/ tx_fail)
    /\ balances' = [ balances EXCEPT ![a, "inj"] = @ - DEPOSIT ]
    /\ active_feeds' = [active_feeds EXCEPT ![m] = a]
    /\ UNCHANGED <<available, total, running_markets, prices>>

\* @type: (ACCOUNT, MARKET) => Bool;
RelayPrice(a, m) ==
    \E price \in Int:
        LET fail == active_feeds[m] /= a IN
        /\ tx' = [ type |-> "relay-price-feed",
               fail |-> fail,
               base |-> m[1],
               quote |-> m[2],
               price |-> price,
               account |-> a ]
        /\ tx_fail' = (fail \/ tx_fail)
        /\ prices' = [ prices EXCEPT ![m] = price ]
        /\ UNCHANGED <<balances, available, total, running_markets, active_feeds>>

PayPlusFee(coins) ==
    \* we make sure that the user has enough coins to pay the taker fee
    (1002 * coins) \div 1000

\* this is a magic formula from the notion spec
IsBuyMargin(margin, price, quantity, market) ==
    LET markPrice == prices[market] IN
    /\ margin * PRECISION >= (quantity * INITIAL_MARGIN_RATIO * price)
    /\ margin * PRECISION >=
       quantity * ((INITIAL_MARGIN_RATIO * markPrice)
            - (markPrice + price) * PRECISION)

\* this is a magic formula from the notion spec
IsSellMargin(margin, price, quantity, market) ==
    LET markPrice == prices[market] IN
    /\ margin * PRECISION >= quantity * INITIAL_MARGIN_RATIO * price
    /\ margin * PRECISION >=
       quantity * (INITIAL_MARGIN_RATIO * markPrice)
            - (price + markPrice) * PRECISION

\* @type: (Str, <<Str, Str>>) => Bool;
CreateDerivativeLimitOrderBuy(a, m) ==
    LET base == m[1]
        quote == m[2]
    IN
    \E quantity, price, margin \in Int:
        LET fail == \/ available[a, base] <= margin
                    \/ quantity <= 0
                    \/ price <= 0
                    \/ ~IsBuyMargin(margin, price, quantity, m)
        IN
        /\ m \in running_markets
        /\ available' = [ available EXCEPT ![a, quote] = @ - margin ]
        /\ tx' = [ type |-> "create-derivative-limit-order",
                   fail |-> fail,
                   direction |-> "buy",
                   base |-> base,
                   quote |-> quote,
                   quantity |-> quantity,
                   price |-> price,
                   margin |-> margin,
                   account |-> a
                 ]
        /\ tx_fail' = (fail \/ tx_fail)
        /\ UNCHANGED <<balances, running_markets, total, active_feeds, prices>>

\* @type: (Str, <<Str, Str>>) => Bool;
CreateDerivativeLimitOrderSell(a, m) ==
    LET base == m[1]
        quote == m[2]
    IN
    \E quantity, price, margin \in Int:
        LET fail ==
            \/ available[a, base] <= margin
            \/ quantity <= 0
            \/ price <= 0
            \/ ~IsSellMargin(margin, price, quantity, m)
        IN
        /\ m \in running_markets
        /\ available' = [ available EXCEPT ![a, base] = @ - quantity ]
        /\ tx' = [ type |-> "create-derivative-limit-order",
                   fail |-> fail,
                   direction |-> "sell",
                   base |-> base,
                   quote |-> quote,
                   quantity |-> quantity,
                   price |-> price,
                   margin |-> margin,
                   account |-> a
                 ]
        /\ tx_fail' = (fail \/ tx_fail)
        /\ UNCHANGED <<balances, running_markets, total, active_feeds, prices>>

Next ==
    \/ \E a \in ACCOUNTS \ {"genesis"}, c \in COINS:
        \/ Deposit(a, c)
        \/ Withdraw(a, c)
    \/ \E a \in ACCOUNTS \ {"genesis"}, m \in MARKETS:
        \/ LaunchInstantFuturesMarket(a, m)
        \/ GrantPriceFeeder(a, m)
        \/ RelayPrice(a, m)
    \/ \E a \in ACCOUNTS \ {"genesis"}, m \in MARKETS:
        \/ CreateDerivativeLimitOrderBuy(a, m)
        \/ CreateDerivativeLimitOrderSell(a, m)

\* restrict to non-failing actions only
NextNoFail ==
    Next /\ ~tx_fail'

===============================================================================
