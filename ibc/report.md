# Report WIP

## Executive Summary

- Informal hired by ICF for Rust dev, formal specs, and testing the Go.
- As part of that, spend a month starting Oct 26 with fresh eyes doing internal review of IBC in Go and
  producing some useful artifacts (tests, specs, code cleanup, etc.)
- IG was reviewing and updating at same time - we started at code hash XXX, but updated somewhat continuously as IG merged code
- First Week: Token transfer. Invariants. Start TLA+ models. See issues.
- Second Week: Channels. Invariants. Start TLA+ models. Capabilities. See issues.
- Third Week: Connections and Clients. Invariants. See issues.
- Fourth Week: Upgrades ? Relayer? ...
- Summary of artifacts.
- Protocol well designed and well implemented
- Spec leaves a lot wanting. 
- Our pre/post conditions should help, but still alot
  of work needed.
- General concerns around crossing hellos, ocaps, and application responsibilities


## Project Summary

*App*
Name: IBC
Version: XXX ++
Type: Spec and Code
Platform: Blockchain

*Engagement*
- Oct 26 - Nov 20
- 5 people part time (?)
- Methodology: ...


*Vulnerability Summary*
- High:
- Medium:
- Low:
- Info:
- Undetermined:

*Category Breakdown*

?

## Engagement Goals

- review spec and code
- produce artifacts
- ...
- See original google doc ... 

## Coverage

- x/ibc ...
- x/cap

## Artifacts 

Links to

- Invariants for major components
    - high level safety+liveness for each component (transfer, channel
      handshake, packets, conn handshake, client)
    - pre and post conditions for all msg handlers
- TLA+ model of token transfer and denom handling 
- Model-based testing of token transfer recvPacket 
- Fuzzing ? Property tests?

## Recommendations Summary

Short Term

- escrow account
- crossing hellos
- client update delays (?)
- other spec fixes
- other ?

Long Term

- clarify error handling in spec and code
- clarify validation in spec and code (eg importance of validate basic and
  deduplicate checks)
- consider improved governance activation of modules 
- 

## Findings Summary

Consolidate and organize findings somewhat and list here:

- Error handling in spec vs code generally 
- Validation rule confusion - checks redundant with validate basic 
- Other common inconsistencies between spec and code
- List of individual actual bugs in the spec and/or code
    - GetEscrowAddress - spec and code
    - x/cap ...
    - LookupModuleByPort
- Crossing hellos
- Capabilities (?)

## Appendix

Severity and Difficulty?
