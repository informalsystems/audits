------------ Module channel ---------

ChannelState == { "INIT", "TRYOPEN", "OPEN", "CLOSED" }

ChannelOrder == { "ORDERED", "UNORDERED" }

ChannelEnd == [
  state: ChannelState
  ordering: ChannelOrder
  counterpartyPortIdentifier: Identifier
  counterpartyChannelIdentifier: Identifier
  connectionHops: Identifier \* I guess this should eventually be a sequence
  version: string
]