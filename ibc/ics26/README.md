# Findings

ICS25 spec:

- "any module may create a new client, query any existing client, update any
  existing client, and delete any existing client not in use."
    - doesnt this mean a malicious modules endblock can always prevent
      connections from being created by just deleting clients?
- what does `SHALL allow external calls to` mean ?
- would be helpful to explicitly call out if any functions are not exposed ?


ICS26 spec
- dont really understand the ICS25 vs ICS26. isnt it just an implementation
  detail, currently coloured by how the SDK works ?
- callbackPath, authenticationPath ? 
- all datagrams are being defined fresh here. is that right? how should this ink
  to the other ics' where they're defined ...


ICS26 Code vs Spec:

- Spec always calls module handler before calling IBC handler. Code alternates
    - eg. ChanOpenInit/Try call the handler first, callback second,
      OpenAck/Confirm do the reverse
        
    - eg. RecvPacket code calls IBC handler first

ICS26:

- all returned results are empty; its always just emiting events. 
- client and conn handlers emit events in outer layer, not in 02/03
- channel handlers emit in 04 and in the app module
- 04 Channel handshake handlers return sdk.Result containing events, but they're ignored
  ...
- app module packet callbacks return sdk.Result containing events, but tehy're
  ignored (onReceive/Timeout/AcknowledgePacket)
- dedup common packet-based telemetry code
- why are handshake methods exposed in 04/handle.go but packet methods are not? 
    - handshake emit events are at package level
    - packet/timeout emit events are in the keeper

- timeout, ontimeoutpacket, timeoutexecuted
- timeoutonclose, ontimeoutpacket, timeoutexecuted


