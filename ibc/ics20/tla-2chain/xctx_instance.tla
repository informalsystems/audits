------------------ MODULE xctx_instance --------

Identifiers == {"","bucky","zarko"}
NullId == ""
MaxAmount == 2
MaxDenomLength== 3
MaxAccountLength == 3
Chains == {"A", "B"}
NativeDenom == {["A" |-> <<"atom">>, "B" |-> <<"bitcoin">>]}
InitialBank == [<<"A", "bucky", "atom">> |-> 5]
InitialEvent == {}

VARIABLES
  error
  bank
  pending  
  step
  upcomingEvent

INSTANCE xctx

===========================================================================