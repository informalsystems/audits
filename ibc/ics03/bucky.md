# Notes

client  height version must equal version in chain id

chainID format: chainid-version


OpenTry - should we require unbonding period to be much larger than
TrustingPeriod ? 

UpgradePath? 


ClientState.Validate:
ConsensusParams.Version never checked for nil but never used
MaxClockDrift should be less than TrustingPeriod ?


IBC does not support amino txs - double check this!

connOpenInit - 
- can only add a connection id once
- client must exist 

look at PickVersion more carefully

Think more about the Verify functions
- how to reason about which ones need to happen?
- look at implementations in the client


timestamps cast between uint64/int64: 
- uint64(ctx.BlockTime().UnixNano()
- GetTimestampAtHeight / GetTimestamp
- probably not a problem since negative time is pre 1970 but still inconsistent
  to use uint64 when the data type is really int64...


