-------------------------- MODULE transfer_instance ----------------------------
Identifiers == {"","bucky","zarko"}
NullId == ""
MaxAmount == 2
Denoms == {"", "atom", "eth" }
AccountIds == {"", "a1", "a2" }

VARIABLES error, bank, p, count, history

INSTANCE transfer

=============================================================================
