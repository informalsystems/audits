------------------------------------ MODULE MC_spots --------------------------
EXTENDS FiniteSets, typedefs

ACCOUNTS == { "user1", "user2", "genesis" }
COINS == { "inj", "atom" }

\* @type: (Str, Str) => <<Str, Str>>;
pair(i, j) == <<i, j>>

MARKETS == { pair("inj", "atom"), pair("atom", "inj") }

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

INSTANCE spots

NoSpotLimit ==
    tx.type /= "create-spot-limit-order"

NoAtoms ==
    tx_fail \/ available["user1", "atom"] = 0

SomeAtoms ==
    tx_fail \/ available["user1", "atom"] >= total["user1", "atom"]

\* @type: Seq(STATE) => Bool;
TraceInvManyOrders(hist) ==
    LET Example ==
        LET \* @type: (TX, ACCOUNT) => Bool;
            IsBuy(ptx, acc) ==
            /\ ptx.type = "create-spot-limit-order"
            /\ ptx.direction = "buy"
            /\ ptx.account = acc
        IN
        LET \* @type: (TX, ACCOUNT) => Bool;
            IsSell(ptx, acc) ==
            /\ ptx.type = "create-spot-limit-order"
            /\ ptx.direction = "sell"
            /\ ptx.account = acc
        IN
        /\ Cardinality({ i \in DOMAIN hist: IsBuy(hist[i].tx, "user1") }) >= 1
        /\ Cardinality({ i \in DOMAIN hist: IsSell(hist[i].tx, "user1") }) >= 1
        /\ Cardinality({ i \in DOMAIN hist: IsBuy(hist[i].tx, "user2") }) >= 1
    IN
    ~Example

\* @type: Seq(STATE) => Bool;
TraceInv1(hist) ==
    \/ Len(hist) < 4
    \/  LET Example ==
            /\ \A i \in DOMAIN hist:
                ~hist[i].tx.fail
            /\ \E i \in DOMAIN hist:
                hist[i].tx.type = "deposit" /\ hist[i].tx.coin = "inj"
            /\ \E i \in DOMAIN hist:
                hist[i].tx.type = "withdraw" /\ hist[i].tx.coin = "inj"
        IN
        ~Example

\* @type: Seq(STATE) => Bool;
TraceInvBuySell(hist) ==
    \/ hist[Len(hist)].tx_fail
    \/ ~\E i, j \in DOMAIN hist:
        /\ hist[i].tx.type = "create-spot-limit-order"
        /\ hist[j].tx.type = "create-spot-limit-order"
        /\ hist[i].tx.direction = "buy"
        /\ hist[j].tx.direction = "sell"
        /\ hist[i].tx.account /= hist[j].tx.account
        /\ hist[i].tx.base = hist[j].tx.base
        /\ hist[i].tx.quote = hist[j].tx.quote
        /\ hist[i].tx.quantity > hist[j].tx.quantity + PRECISION
        /\ hist[i].tx.price >= hist[j].tx.price + PRECISION

\* @type: Seq(STATE) => Bool;
TraceInvOutstandingSell(hist) ==
    LET Violation ==
      /\ ~hist[Len(hist)].tx_fail
      /\ LET last == hist[Len(hist)] IN
         /\ last.tx.type = "create-spot-limit-order"
         /\ last.tx.direction = "sell"
         /\ last.tx.quantity >= 10000 * PRECISION
      /\ \A i \in DOMAIN hist:
         \/ hist[i].tx.type /= "create-spot-limit-order"
         \/ hist[i].tx.direction /= "buy"
    IN
    ~Violation

\* @type: Seq(STATE) => Bool;
TraceInvOutstandingSellAndDemolished(hist) ==
    LET Violation ==
      /\ ~hist[Len(hist)].tx_fail
      /\ Len(hist) > 2
      /\ LET sell == hist[Len(hist) - 1] IN
         /\ sell.tx.type = "create-spot-limit-order"
         /\ sell.tx.direction = "sell"
         /\ sell.tx.quantity >= 10000 * PRECISION
      /\ LET demolish == hist[Len(hist)] IN
         /\ demolish.tx.type = "set-spot-market-status"
         /\ demolish.tx.status = "Demolished"
      /\ \A i \in DOMAIN hist:
         \/ hist[i].tx.type /= "create-spot-limit-order"
         \/ hist[i].tx.direction /= "buy"
    IN
    ~Violation

\* use this view to enumerate various scenarios
TxView ==
    <<tx.type, tx_fail>>
    
===============================================================================
