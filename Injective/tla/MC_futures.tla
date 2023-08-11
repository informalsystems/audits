---------------------------- MODULE MC_futures --------------------------
EXTENDS FiniteSets, typedefs_futures

ACCOUNTS == { "user1", "user2", "user3" }
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
    \* active price feeds, one per market
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

INSTANCE futures

\* @type: Seq(STATE) => Bool;
TraceInvFuturesLaunch(hist) ==
    LET Example ==
      /\ ~hist[Len(hist)].tx_fail
      /\ \E i \in DOMAIN hist:
         LET st == hist[i] IN
         st.tx.type = "expiryfuturesmarket-launch"
      /\ \E i \in DOMAIN hist:
         LET st == hist[i] IN
         st.tx.type = "relay-price-feed"
    IN
    ~Example

\* @type: Seq(STATE) => Bool;
TraceInvBuySell(hist) ==
    \/ hist[Len(hist)].tx_fail
    \/ ~\E i, j \in DOMAIN hist:
        /\ hist[i].tx.type = "create-derivative-limit-order"
        /\ hist[j].tx.type = "create-derivative-limit-order"
        /\ hist[i].tx.direction = "buy"
        /\ hist[j].tx.direction = "sell"
        /\ hist[i].tx.account /= hist[j].tx.account
        /\ hist[i].tx.base = hist[j].tx.base
        /\ hist[i].tx.quote = hist[j].tx.quote
        /\ hist[i].tx.quantity > hist[j].tx.quantity + PRECISION
        /\ hist[i].tx.price >= hist[j].tx.price + PRECISION

InvBuyForNegativePrice ==
    \/ tx_fail
    \/ LET Example ==
         LET base == tx.base IN
         LET quote == tx.quote IN
         /\ tx.type = "create-derivative-limit-order"
         /\ tx.direction = "buy"
         /\ prices[pair(base, quote)] < -10 * PRECISION
         /\ tx.quantity >= 1000
        IN  
        ~Example

\* @type: Seq(STATE) => Bool;
TraceInvBuySellNegative(hist) ==
    \/ hist[Len(hist)].tx_fail
    \/ Len(hist) < 9
    \/  LET sell == hist[Len(hist) - 2] IN
        LET buy == hist[Len(hist) - 1] IN
        LET hack == hist[Len(hist)] IN
        LET base == sell.tx.base IN
        LET quote == sell.tx.quote IN
        LET max_price == -(2^254 - 1) IN
        LET Example ==
            /\ buy.tx.type = "create-derivative-limit-order"
            /\ sell.tx.type = "create-derivative-limit-order"
            /\ buy.tx.direction = "buy"
            /\ sell.tx.direction = "sell"
            /\ buy.tx.account /= sell.tx.account
            /\ buy.tx.base = sell.tx.base
            /\ buy.tx.quote = sell.tx.quote
            /\ buy.tx.quantity >= sell.tx.quantity
            /\ buy.tx.price >= sell.tx.price
            /\ buy.prices[pair(base, quote)] = PRECISION
            /\ sell.prices[pair(base, quote)] = PRECISION
            /\ hack.prices[pair(base, quote)] = max_price
        IN ~Example

\* use this view to enumerate various scenarios
TxView ==
    <<tx.type, tx_fail>>
    
===============================================================================
