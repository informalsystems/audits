

lots of functions that are not fallible in the spec are fallible in the code
- eg. many calls to Get from provable store
- should these panic in the code? differentiate between developer error and user
  errror
    - eg. ics04 RecPacket GetNextS


TODO
run test coverage and look for uncovered points ?


if you release a capability and someone else maliciously finds it, is that a
    problem?


----

TOOLING:
- test that each field in a struct has a check in its ValidateBasic ... pointers
  check for nil, etc.

Q:
- if something goes wrong/error, what info do we get out ? how good is error
  reporting?



TWO GOALS:

1. for user of token transfer - app is sound. these are expectations IBC should provide. some proofs
2. ibc app developers - we can help


what are the guarantees of IBC that are critical to a given application?



``` all func Whatever 
grep "func [a-zA-Z]" -r --exclude="*test.go" --exclude="*.pb*go"  . 
```

---



how can we check account balances are correct in invariants in transfer module ... it doesnt have access to accounts ...

ensure slashes and "ibc" are not allowed in coin denoms ...

denom hashing isnt mentioned at all in the spec

what happens to channel when client expires?

--------------------

can the module really only bind one port? genesis.go suggests so 

------------

relayer must query ports, channels, and next hop back 

---------

Run the simulator:

```
go test ./simapp/ -run TestFullAppSim -NumBlocks=5 -Enabled=true -Period 1 -Commit -v -timeout 24h
```

See flag options in simapp/config.go

--------

Simulator operations are returned from each module via `WeightedOperations` method.

Note IBC currently has none (!)

--------

Invariants are registered in the `crisis` module and checked in the EndBlock periodically: crisis/abci.go

each module has its own `RegisterInvariants` method

The current set of invariants seems quite limited!!


------

Findings:

AppModule.EndBlock doesn't allow updating the Tendermint ConsensusParams ...
Simulator is broken when it finds a bug : `        CRITICAL please submit the following transaction: `tx crisis invariant-broken gov module-account [recovered]`
runMsgs break in for loop for checktx is silly ... 
