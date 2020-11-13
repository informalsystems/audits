------------------ MODULE xctx_instance --------

Identifiers == {"","bucky","zarko"}
AccountIds == {<<"">>, <<"a1">>, <<"a2">> }
NullId == ""
MaxAmount == 2
MaxDenomLength== 3
MaxAccountLength == 3
Chains == {"A", "B"}
NativeDenom == [x \in {"A", "B"} |-> IF x = "A" THEN <<"atom">> ELSE <<"bitcoin">>]
InitialBank == [x \in {<<"A", "a1", "atom">>} |-> 5]
BigBang == [
packet |-> 
    [
    sourcePort |-> "bucky", 
    sourceChannel |-> "bucky",
    destPort |-> "zarko", 
    destChannel |-> "zarko", 
    data |-> [ 
        sender |-> <<"a1">>, 
        receiver |-> <<"a2">>, 
        denom |-> <<"atom">>, 
        amount |-> 3]
    ], 
function |-> "snd", 
chain |-> "A"
]
AtMostOnce == TRUE
AsChain == [ x \in {<<"zarko", "zarko">>, <<"bucky", "bucky">> }|-> 
    IF x = <<"bucky", "bucky">> THEN "A" ELSE "B" ]



VARIABLES
  error,
  bank,
  pending,  
  step,
  upcomingEvent

 INSTANCE xctx

=======================================================================