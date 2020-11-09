------------------------- MODULE counterexample -------------------------

EXTENDS transfer_instance

(* Initial state *)

State1 ==
TRUE
(* Transition 0 to State2 *)

State2 ==
/\ bank = <<
    [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
      denom |-> "",
      port |-> ""]
  >>
    :> 0
/\ count = 0
/\ error = FALSE
/\ history = 0
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 0,
              denomTrace |-> [channel |-> "", denom |-> "eth", port |-> "zarko"],
              receiver |-> "a2",
              sender |-> "a2"],
          destChannel |-> "bucky",
          destPort |-> "zarko",
          sourceChannel |-> "bucky",
          sourcePort |-> "zarko"]]
/\ p = [data |->
    [amount |-> 0,
      denomTrace |-> [channel |-> "", denom |-> "eth", port |-> "zarko"],
      receiver |-> "a2",
      sender |-> "a2"],
  destChannel |-> "bucky",
  destPort |-> "zarko",
  sourceChannel |-> "bucky",
  sourcePort |-> "zarko"]

(* Transition 0 to State3 *)

State3 ==
/\ bank = <<
    [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
      denom |-> "",
      port |-> ""]
  >>
    :> 0
/\ count = 1
/\ error = FALSE
/\ history = 0
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 0,
              denomTrace |-> [channel |-> "", denom |-> "eth", port |-> "zarko"],
              receiver |-> "a2",
              sender |-> "a2"],
          destChannel |-> "bucky",
          destPort |-> "zarko",
          sourceChannel |-> "bucky",
          sourcePort |-> "zarko"]]
  @@ 1
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "bucky", denom |-> "atom", port |-> "zarko"],
              receiver |-> "a1",
              sender |-> ""],
          destChannel |-> "zarko",
          destPort |-> "zarko",
          sourceChannel |-> "bucky",
          sourcePort |-> "bucky"]]
/\ p = [data |->
    [amount |-> 1,
      denomTrace |-> [channel |-> "bucky", denom |-> "atom", port |-> "zarko"],
      receiver |-> "a1",
      sender |-> ""],
  destChannel |-> "zarko",
  destPort |-> "zarko",
  sourceChannel |-> "bucky",
  sourcePort |-> "bucky"]

(* Transition 1 to State4 *)

State4 ==
/\ bank = <<
    [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
      denom |-> "",
      port |-> ""]
  >>
    :> 0
  @@ <<
    [channel |-> "", id |-> "a1", port |-> ""], [channel |-> "zarko",
      denom |-> "atom",
      port |-> "zarko"]
  >>
    :> 1
/\ count = 2
/\ error = FALSE
/\ history = 0
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 0,
              denomTrace |-> [channel |-> "", denom |-> "eth", port |-> "zarko"],
              receiver |-> "a2",
              sender |-> "a2"],
          destChannel |-> "bucky",
          destPort |-> "zarko",
          sourceChannel |-> "bucky",
          sourcePort |-> "zarko"]]
  @@ 1
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "bucky", denom |-> "atom", port |-> "zarko"],
              receiver |-> "a1",
              sender |-> ""],
          destChannel |-> "zarko",
          destPort |-> "zarko",
          sourceChannel |-> "bucky",
          sourcePort |-> "bucky"]]
  @@ 2
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 0,
              denomTrace |->
                [channel |-> "zarko", denom |-> "atom", port |-> "zarko"],
              receiver |-> "a1",
              sender |-> "a2"],
          destChannel |-> "zarko",
          destPort |-> "zarko",
          sourceChannel |-> "bucky",
          sourcePort |-> "bucky"]]
/\ p = [data |->
    [amount |-> 0,
      denomTrace |-> [channel |-> "zarko", denom |-> "atom", port |-> "zarko"],
      receiver |-> "a1",
      sender |-> "a2"],
  destChannel |-> "zarko",
  destPort |-> "zarko",
  sourceChannel |-> "bucky",
  sourcePort |-> "bucky"]

(* Transition 0 to State5 *)

State5 ==
/\ bank = <<
    [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
      denom |-> "",
      port |-> ""]
  >>
    :> 0
  @@ <<
    [channel |-> "", id |-> "a1", port |-> ""], [channel |-> "zarko",
      denom |-> "atom",
      port |-> "zarko"]
  >>
    :> 1
/\ count = 3
/\ error = FALSE
/\ history = 0
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 0,
              denomTrace |-> [channel |-> "", denom |-> "eth", port |-> "zarko"],
              receiver |-> "a2",
              sender |-> "a2"],
          destChannel |-> "bucky",
          destPort |-> "zarko",
          sourceChannel |-> "bucky",
          sourcePort |-> "zarko"]]
  @@ 1
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "bucky", denom |-> "atom", port |-> "zarko"],
              receiver |-> "a1",
              sender |-> ""],
          destChannel |-> "zarko",
          destPort |-> "zarko",
          sourceChannel |-> "bucky",
          sourcePort |-> "bucky"]]
  @@ 2
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 0,
              denomTrace |->
                [channel |-> "zarko", denom |-> "atom", port |-> "zarko"],
              receiver |-> "a1",
              sender |-> "a2"],
          destChannel |-> "zarko",
          destPort |-> "zarko",
          sourceChannel |-> "bucky",
          sourcePort |-> "bucky"]]
  @@ 3
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |-> [channel |-> "zarko", denom |-> "", port |-> ""],
              receiver |-> "",
              sender |-> "a1"],
          destChannel |-> "",
          destPort |-> "",
          sourceChannel |-> "",
          sourcePort |-> ""]]
/\ p = [data |->
    [amount |-> 1,
      denomTrace |-> [channel |-> "zarko", denom |-> "", port |-> ""],
      receiver |-> "",
      sender |-> "a1"],
  destChannel |-> "",
  destPort |-> "",
  sourceChannel |-> "",
  sourcePort |-> ""]

(* Transition 0 to State6 *)

State6 ==
/\ bank = <<
    [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
      denom |-> "",
      port |-> ""]
  >>
    :> 0
  @@ <<
    [channel |-> "", id |-> "a1", port |-> ""], [channel |-> "zarko",
      denom |-> "atom",
      port |-> "zarko"]
  >>
    :> 1
/\ count = 4
/\ error = TRUE
/\ history = 0
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 0,
              denomTrace |-> [channel |-> "", denom |-> "eth", port |-> "zarko"],
              receiver |-> "a2",
              sender |-> "a2"],
          destChannel |-> "bucky",
          destPort |-> "zarko",
          sourceChannel |-> "bucky",
          sourcePort |-> "zarko"]]
  @@ 1
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "bucky", denom |-> "atom", port |-> "zarko"],
              receiver |-> "a1",
              sender |-> ""],
          destChannel |-> "zarko",
          destPort |-> "zarko",
          sourceChannel |-> "bucky",
          sourcePort |-> "bucky"]]
  @@ 2
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 0,
              denomTrace |->
                [channel |-> "zarko", denom |-> "atom", port |-> "zarko"],
              receiver |-> "a1",
              sender |-> "a2"],
          destChannel |-> "zarko",
          destPort |-> "zarko",
          sourceChannel |-> "bucky",
          sourcePort |-> "bucky"]]
  @@ 3
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |-> [channel |-> "zarko", denom |-> "", port |-> ""],
              receiver |-> "",
              sender |-> "a1"],
          destChannel |-> "",
          destPort |-> "",
          sourceChannel |-> "",
          sourcePort |-> ""]]
  @@ 4
    :> [error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 0,
              denomTrace |-> [channel |-> "", denom |-> "", port |-> ""],
              receiver |-> "",
              sender |-> ""],
          destChannel |-> "",
          destPort |-> "",
          sourceChannel |-> "",
          sourcePort |-> ""]]
/\ p = [data |->
    [amount |-> 0,
      denomTrace |-> [channel |-> "", denom |-> "", port |-> ""],
      receiver |-> "",
      sender |-> ""],
  destChannel |-> "",
  destPort |-> "",
  sourceChannel |-> "",
  sourcePort |-> ""]

(* The following formula holds true in the last state and violates the invariant *)

InvariantViolation == count >= 4

================================================================================
\* Created by Apalache on Thu Nov 05 20:57:36 CET 2020
\* https://github.com/informalsystems/apalache
