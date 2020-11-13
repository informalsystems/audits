If
[this](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/applications/transfer/keeper/relay.go#L284)
fails 

- then an error is returned to
  [here](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/applications/transfer/module.go#L315)
  so that an ACK is set

- then
  [here](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/applications/transfer/module.go#L332)
  we return (_, ACK, nil) 
  
- it is returned to [here](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/core/keeper/msg_server.go#L439)

- so acknowledgment is written [here](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/core/keeper/msg_server.go#L448)

- thus, we return normally
  [here](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/core/keeper/msg_server.go#L466)
  

As a result

- Coins were generated
  [here](https://github.com/cosmos/cosmos-sdk/blob/7e6978ae551bbed439c69178184dea0a25d0e747/x/ibc/applications/transfer/keeper/relay.go#L274)
- on the sender chain, we roll back due to the ack.
