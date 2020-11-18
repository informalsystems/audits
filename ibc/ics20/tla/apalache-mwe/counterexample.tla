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
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "buckybucky", denom |-> "", port |-> ""],
              receiver |-> "a1",
              sender |-> "a2"],
          destChannel |-> "",
          destPort |-> "",
          sourceChannel |-> "buckybucky",
          sourcePort |-> "zarkozarko"]]
/\ p = [data |->
    [amount |-> 1,
      denomTrace |-> [channel |-> "buckybucky", denom |-> "", port |-> ""],
      receiver |-> "a1",
      sender |-> "a2"],
  destChannel |-> "",
  destPort |-> "",
  sourceChannel |-> "buckybucky",
  sourcePort |-> "zarkozarko"]

(* Transition 1 to State3 *)

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
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "buckybucky", denom |-> "", port |-> ""],
              receiver |-> "a1",
              sender |-> "a2"],
          destChannel |-> "",
          destPort |-> "",
          sourceChannel |-> "buckybucky",
          sourcePort |-> "zarkozarko"]]
  @@ 1
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "buckybucky", denom |-> "", port |-> ""],
              receiver |-> "a1",
              sender |-> "a2"],
          destChannel |-> "",
          destPort |-> "",
          sourceChannel |-> "buckybucky",
          sourcePort |-> "zarkozarko"]]
/\ p = [data |->
    [amount |-> 1,
      denomTrace |->
        [channel |-> "zarkozarko", denom |-> "eth", port |-> "buckybucky"],
      receiver |-> "",
      sender |-> ""],
  destChannel |-> "buckybucky",
  destPort |-> "zarkozarko",
  sourceChannel |-> "zarkozarko",
  sourcePort |-> "buckybucky"]

(* Transition 0 to State4 *)

State4 ==
/\ bank = <<
    [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
      denom |-> "",
      port |-> ""]
  >>
    :> 0
/\ count = 2
/\ error = FALSE
/\ history = 0
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "buckybucky", denom |-> "", port |-> ""],
              receiver |-> "a1",
              sender |-> "a2"],
          destChannel |-> "",
          destPort |-> "",
          sourceChannel |-> "buckybucky",
          sourcePort |-> "zarkozarko"]]
  @@ 1
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "buckybucky", denom |-> "", port |-> ""],
              receiver |-> "a1",
              sender |-> "a2"],
          destChannel |-> "",
          destPort |-> "",
          sourceChannel |-> "buckybucky",
          sourcePort |-> "zarkozarko"]]
  @@ 2
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "zarkozarko",
                  denom |-> "eth",
                  port |-> "buckybucky"],
              receiver |-> "",
              sender |-> ""],
          destChannel |-> "buckybucky",
          destPort |-> "zarkozarko",
          sourceChannel |-> "zarkozarko",
          sourcePort |-> "buckybucky"]]
/\ p = [data |->
    [amount |-> 0,
      denomTrace |-> [channel |-> "", denom |-> "atom", port |-> "buckybucky"],
      receiver |-> "a2",
      sender |-> "a1"],
  destChannel |-> "zarkozarko",
  destPort |-> "zarkozarko",
  sourceChannel |-> "",
  sourcePort |-> ""]

(* Transition 1 to State5 *)

State5 ==
/\ bank = <<
    [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
      denom |-> "",
      port |-> ""]
  >>
    :> 0
/\ count = 3
/\ error = FALSE
/\ history = 0
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "buckybucky", denom |-> "", port |-> ""],
              receiver |-> "a1",
              sender |-> "a2"],
          destChannel |-> "",
          destPort |-> "",
          sourceChannel |-> "buckybucky",
          sourcePort |-> "zarkozarko"]]
  @@ 1
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "buckybucky", denom |-> "", port |-> ""],
              receiver |-> "a1",
              sender |-> "a2"],
          destChannel |-> "",
          destPort |-> "",
          sourceChannel |-> "buckybucky",
          sourcePort |-> "zarkozarko"]]
  @@ 2
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "zarkozarko",
                  denom |-> "eth",
                  port |-> "buckybucky"],
              receiver |-> "",
              sender |-> ""],
          destChannel |-> "buckybucky",
          destPort |-> "zarkozarko",
          sourceChannel |-> "zarkozarko",
          sourcePort |-> "buckybucky"]]
  @@ 3
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 0,
              denomTrace |->
                [channel |-> "", denom |-> "atom", port |-> "buckybucky"],
              receiver |-> "a2",
              sender |-> "a1"],
          destChannel |-> "zarkozarko",
          destPort |-> "zarkozarko",
          sourceChannel |-> "",
          sourcePort |-> ""]]
/\ p = [data |->
    [amount |-> 1,
      denomTrace |->
        [channel |-> "zarkozarko", denom |-> "eth", port |-> "zarkozarko"],
      receiver |-> "",
      sender |-> ""],
  destChannel |-> "buckybucky",
  destPort |-> "buckybucky",
  sourceChannel |-> "zarkozarko",
  sourcePort |-> "zarkozarko"]

(* Transition 0 to State6 *)

State6 ==
/\ bank = <<
    [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
      denom |-> "",
      port |-> ""]
  >>
    :> 0
/\ count = 4
/\ error = FALSE
/\ history = 0
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "buckybucky", denom |-> "", port |-> ""],
              receiver |-> "a1",
              sender |-> "a2"],
          destChannel |-> "",
          destPort |-> "",
          sourceChannel |-> "buckybucky",
          sourcePort |-> "zarkozarko"]]
  @@ 1
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "buckybucky", denom |-> "", port |-> ""],
              receiver |-> "a1",
              sender |-> "a2"],
          destChannel |-> "",
          destPort |-> "",
          sourceChannel |-> "buckybucky",
          sourcePort |-> "zarkozarko"]]
  @@ 2
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "zarkozarko",
                  denom |-> "eth",
                  port |-> "buckybucky"],
              receiver |-> "",
              sender |-> ""],
          destChannel |-> "buckybucky",
          destPort |-> "zarkozarko",
          sourceChannel |-> "zarkozarko",
          sourcePort |-> "buckybucky"]]
  @@ 3
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 0,
              denomTrace |->
                [channel |-> "", denom |-> "atom", port |-> "buckybucky"],
              receiver |-> "a2",
              sender |-> "a1"],
          destChannel |-> "zarkozarko",
          destPort |-> "zarkozarko",
          sourceChannel |-> "",
          sourcePort |-> ""]]
  @@ 4
    :> [bankAfter |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      bankBefore |->
        <<
            [channel |-> "", id |-> "", port |-> ""], [channel |-> "",
              denom |-> "",
              port |-> ""]
          >>
            :> 0,
      error |-> FALSE,
      packet |->
        [data |->
            [amount |-> 1,
              denomTrace |->
                [channel |-> "zarkozarko",
                  denom |-> "eth",
                  port |-> "zarkozarko"],
              receiver |-> "",
              sender |-> ""],
          destChannel |-> "buckybucky",
          destPort |-> "buckybucky",
          sourceChannel |-> "zarkozarko",
          sourcePort |-> "zarkozarko"]]
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

InvariantViolation == count = 4

================================================================================
\* Created by Apalache on Wed Nov 18 12:07:05 CET 2020
\* https://github.com/informalsystems/apalache
