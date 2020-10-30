-------------------------- MODULE accounts_instance ----------------------------
Identifiers == {"","bucky","zarko"}
NullId == ""
MaxAmount == 2
MaxDenomLength== 3
MaxAccountLength == 3
NativeDenom == <<"bucky">>

VARIABLES bank,p

INSTANCE accounts

=============================================================================
