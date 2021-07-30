------------------------------ MODULE typedefs --------------------------------
\* @typeAlias: ACCOUNT = Str;
\* @typeAlias: COIN = Str;
\* @typeAlias: BALANCE = <<ACCOUNT, COIN>> -> Int;
\* @typeAlias: MARKET =  <<COIN, COIN>>;
\* @typeAlias: TX = [type: Str, fail: Bool, account: ACCOUNT, coin: COIN,
\*                   base: COIN, quote: COIN, quantity: Int, price: Int,
\*                   direction: Str, status: Str];
\* @typeAlias: STATE = [ balances: BALANCE, available: BALANCE, total: BALANCE,
\*                       tx: TX, running_markets: Set(MARKET), tx_fail: Bool ];
\*
\* a dummy definition to define aliases
typedefs_aliases == FALSE

===============================================================================
