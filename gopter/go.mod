module github.com/informalsystems/audits/gopter

go 1.14

require (
	github.com/cosmos/cosmos-sdk v0.34.4-0.20201028192045-82f15f306e8a
	github.com/leanovate/gopter v0.2.8
	github.com/stretchr/testify v1.6.1
	github.com/tendermint/tendermint v0.34.0-rc5
	github.com/tendermint/tm-db v0.6.2
)

replace github.com/gogo/protobuf => github.com/regen-network/protobuf v1.3.2-alpha.regen.4
