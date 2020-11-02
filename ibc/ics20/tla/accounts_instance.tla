-------------------------- MODULE accounts_instance ----------------------------
Identifiers == {"","bucky","zarko"}
NullId == ""
MaxAmount == 2
MaxDenomLength== 3
MaxAccountLength == 3
NativeDenom == <<"bucky">>
NInitBankAccounts == 3

VARIABLES error, bank, p

INSTANCE accounts

=============================================================================
