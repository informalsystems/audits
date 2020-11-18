-------------------------- MODULE transfer_instance ----------------------------
Identifiers == {"","buckybucky","zarkozarko"}
NullId == ""
MaxAmount == 2
Denoms == {"", "atom", "eth" }
AccountIds == {"", "a1", "a2" }
MaxDenomLength == 3

VARIABLES error, bank, p, count, history

INSTANCE transfer

=============================================================================
