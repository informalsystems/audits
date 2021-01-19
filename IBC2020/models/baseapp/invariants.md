# Baseapp

The SDK provides an execution environment for transactions in a replicated state
machine and a framework for building such state machines. 
Transactions are assumed to be committed by the state machine replication engine
("consensus") in batches called blocks. Transactions in a committed block are
then executed, sequentially, in order, by the SDK.

State machines built with the SDK are composed from modules. Each module is a distinct component of
the application, typically with its own store and its own set of messages and
handlers that can be triggered by transactions. Transactions contain messages
which are routed to their respective module to be executed. Each message type is processed
by a single module - for instance all staking related messages (create
validator, edit validator, delegate, undelegate, redelegate) are handled by the
staking module.

Messages are effectively the payload of the transaction, containing the input
data for processing by modules. 

But transactions also contain authentication data which ensure the tx (ie. list of messages) 
can be executed in the first place. 

Authentication data in the SDK consists of the following components:
- signatures - ensures there is permission for the sender to execute the particular messages
- nonces - ensures the same tx is not executed more than once (often called "replay prevention", but also the "Uniform Integrity" property of atomic broadcast)
- fees - ensures execution is economically compensated

Tx authentication is performed by the `AnteHandler` in the `x/auth` module,
prior to execution of messages by module handlers. 
AnteHandler is so named because it takes place before, and guards access to, the real handlers,
like an ante in poker games. 

Tendermint provides two ABCI methods for executing txs: CheckTx and DeliverTx.
CheckTx is called when a tx enters the mempool, but before it is included in a
block. Correct nodes reject transactions that do not pass CheckTx. DeliverTx is
called for each tx in a block once the block is committed by consensus. Blocks
from correct proposers will only contain txs that passed CheckTx.

At the SDK level, CheckTx does not necessarily execute the tx in full - it
primarily runs the AnteHandler to validate the authentication data. The
authentication data is enough to ensure validators will be compensated
economically for including the tx in the block, so there is no need to execute
the actual tx msgs in CheckTx.

The workhorse of both CheckTx and DeliverTx in the SDK is the runTx function. It
takes a `mode` parameter which determines if its running in CheckTx or
DeliverTx. Here instead we define distinct functions runDeliverTx and
runCheckTx.

Notes:
- the total gas used by all transactions in a block is bound by a MaxGas
  parameter
- see all [checks done by
  AnteHandler](https://github.com/cosmos/cosmos-sdk/blob/master/x/auth/ante/ante.go#L12)

### runDeliverTx(txBytes)

preconditions:
- block is not out of gas
- txBytes deserializes to tx
- for msg in tx.Msgs, msg.ValidateBasic() is true
- ...

postconditions:
- if preconditions are not satisfied, abort 
- if anteHandler returns error
    - ...
- else 
    - ...
- if runMsgs returns error
    - ...
- else 
    - ...
- block gas meter is incremented by gas used 
- returns msg results and events
- state changes are persisted
- ...

### runCheckTx(txBytes)

preconditions:
- txBytes deserializes to tx
- for msg in tx.Msgs, msg.ValidateBasic() is true
- ...

postconditions:
- if anteHandler returns error
    - ...
- else 
    - ...
- result is empty
- ...
