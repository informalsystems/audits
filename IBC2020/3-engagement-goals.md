# Engagement Goals

This audit was scoped by the Informal Systems team in order to assess the correctness and security of the IBC Go 
implementation. The timing of this internal audit coincides with the upcoming deployment of the IBC protocol to the 
Cosmos Hub, which marks a critical release in the evolution of the Cosmos Network – the ability for arbitrary blockchains 
to communicate with one another. The primary focus of the audit was on the upcoming Stargate launch, but
we also reviewed the code and specification from the IBC as a development environment perspective
for cross-chain applications. Therefore, not all findings present issues with the existing code but might 
become security vulnerability in the context of IBC applications and new implementations of the IBC specifications.   

Specifically, during the audit, we sought to answer the following questions:

- Is the protocol defined unambiguously?
- Are there discrepancies between the code and the specifications?
- Are the stated properties and invariants ambiguous? Can we find violations of the properties and invariants?
- Are IBC messages correctly validated?
- How is error handling and checking state validity done? Are invalid transactions handled correctly? 
  Can malicious inputs cause crashes or invalid states?
- Is the code/specification organized in a way that simplifies reviews?

