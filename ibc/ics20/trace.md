- An error in an external module
[here](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/applications/transfer/keeper/relay.go#L224)
(or
[here](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/applications/transfer/keeper/relay.go#L277))
or
[here](
https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/applications/transfer/keeper/relay.go#L284)

- is returned to
  [here](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/applications/transfer/module.go#L315)
  so that an ACK is set

- then
  [here](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/applications/transfer/module.go#L332)
  we return (_, ACK, nil) 
  
- it is returned to [here](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/core/keeper/msg_server.go#L439)

- so acknowledgment is written [here](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/core/keeper/msg_server.go#L448)

- thus, we return normally
  [here](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/core/keeper/msg_server.go#L466)
  
- It seems that depending on the error that started the trace, we have
  performed some state change at the receiver, while the sender will
  roll back due to the ack returned.
  

