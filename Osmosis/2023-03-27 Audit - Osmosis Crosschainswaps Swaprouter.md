
#  Osmosis Phase 3 Audit performed in 2023/Q1

The scope for the audit in 2023/Q1 is the [ibc-hooks module](https://github.com/osmosis-labs/osmosis/tree/main/x/ibc-hooks) and two smart contracts: [crosschainswaps](https://github.com/osmosis-labs/osmosis/tree/main/cosmwasm/contracts/crosschain-swaps) and [swaprouter](https://github.com/osmosis-labs/osmosis/tree/main/cosmwasm/contracts/swaprouter).

MoMs of the sync meetings are found in the folder: [SyncMoMs](../Q1/SyncMoMs/)

#  Deliverables:
 ## Issues ##

Issues reported on Osmosis Lab github repositories:
- Validation of string length is not present [#3664](https://github.com/osmosis-labs/osmosis/issues/4492)

Other findings are not requested by Osmosis team to be reported as issues. 

## Findings ##

- [Missing authorization in smart contracts](../Q1/findings/IF-OSMOSIS-CONTRACTS-AUTHORIZATION.md)
- [Loading from ROUTING_TABLE optimization](../Q1/findings/IF-OSMOSIS-LOADING-OPTIMIZAITON.md)
- [Minor code changes recommendations](../Q1/findings/IF-OSMOSIS-MINOR-CHANGES.md)
- [RECOVERY_STATES contract state not cleared after loading](../Q1/findings/IF-OSMOSIS-RECOVERY-STATE-PERSISTANCE.md)
- [Validation of string length validation is not present](../Q1/findings/IF-OSMOSIS-STRING-LENGTH-VALIDATION.md)
- [SWAP REPLY STATE optimization](../Q1/findings/IF-OSMOSIS-SWAP-REPLY-OPTIMIZATION.md)
- [Usage of Rust's unwrap function is not recommended](../Q1/findings/IF-OSMOSIS-UNWRAP-USAGE.md)

## Analysis & testing document ## 

Document describing ics-20 fungible token transfer properties and end-to-end test scenarios and their execution is located [here](Token-Transfer-Analysis-and-Testing.md). 
 

 

