# Fuzzing

This is a workspace for fuzzing functions from the SDK using
[go-fuzz](https://github.com/dvyukov/go-fuzz).

See the go-fuzz README for installation and directions.

You can build the fuzzer binary by running `go-fuzz-build`. It should create 
`fuzz-fuzz.zip`. 

The `workdir/corpus` was populated with a single `example` file which was taken
from a tx which caused a panic a few weeks ago (ie. when Andy was testing
incomplete txs from Rust and opened
https://github.com/cosmos/cosmos-sdk/issues/7585). I simply copied the
transaction hex from there, decoded it to bytes and wrote the bytes to
`workdir/corpus/example`.

Then run the fuzzer with `go-fuzz -bin=fuzz-fuzz.zip -workdir=workdir`.

It should quickly find crashes. I encoded one of the inputs to hex and tested it
explicitly in `fuzz_test.go` and opened an issue about it in
https://github.com/cosmos/cosmos-sdk/issues/7739

We should generate more corpus data from the SDK code by looking at how
transactions are generated for the simulator. We can probably create hundres of
example transactions from there and give the fuzzer much more to work with.

We should extend this fuzz test to also:

- re serialize the deserialized tx and compare to the input
- run ValidateBasic on all messages
- ... ?

We should also consider other targets besides the TxDecoder, like objects read
from/written to storage.

We can also use fuzz the CheckTx and DeliverTx methods instead of the TxDecoder
but that requires setting up a larger Application object and those functions are
suppose to recover from panics so they might be harder to trigger.
