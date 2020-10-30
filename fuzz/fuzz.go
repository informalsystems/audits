package fuzz

import "github.com/cosmos/cosmos-sdk/simapp"

func Fuzz(data []byte) int {
	cfg := simapp.MakeTestEncodingConfig()
	decoder := cfg.TxConfig.TxDecoder()
	decoder(data)
	return 0
}
