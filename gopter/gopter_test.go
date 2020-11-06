package keeper_test

import (
	"fmt"
	"testing"

	sdk "github.com/cosmos/cosmos-sdk/types"
	banktypes "github.com/cosmos/cosmos-sdk/x/bank/types"
	"github.com/cosmos/cosmos-sdk/x/capability/keeper"
	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/commands"
	gopterGen "github.com/leanovate/gopter/gen"
)

type sys struct {
	ctx    sdk.Context
	keeper *keeper.Keeper
	scoped keeper.ScopedKeeper
}

type newCommand uint8

func (value newCommand) Run(q commands.SystemUnderTest) commands.Result {
	s := q.(*sys)

	nameIdx := normalize(uint8(value), 5)
	name := string([]byte{65 + byte(nameIdx)})
	s.scoped.NewCapability(s.ctx, name)
	return s
}

func (newCommand) PostCondition(state commands.State, result commands.Result) *gopter.PropResult {
	st := result.(*sys)
	ok := checkGet(st.ctx, st.keeper, st.scoped)
	if !ok {
		return &gopter.PropResult{Status: gopter.PropFalse}
	}
	return &gopter.PropResult{Status: gopter.PropTrue}
}

func (value newCommand) NextState(state commands.State) commands.State {
	s := state.(*sys)
	return s
}

func (newCommand) PreCondition(state commands.State) bool {
	return true
}

func (value newCommand) String() string {
	return fmt.Sprintf("New(%d)", value)
}

var genNewCommand = gopterGen.UInt8().Map(func(value uint8) commands.Command {
	return newCommand(value)
}).WithShrinker(func(v interface{}) gopter.Shrink {
	return gopterGen.UInt8Shrinker(uint8(v.(newCommand))).Map(func(value uint8) newCommand {
		return newCommand(value)
	})

})

func cbCommands(t *testing.T) *commands.ProtoCommands {
	return &commands.ProtoCommands{
		NewSystemUnderTestFunc: func(initState commands.State) commands.SystemUnderTest {
			return initState
		},
		InitialStateGen: func(p *gopter.GenParameters) *gopter.GenResult {
			ctx, capKeeper := initKeeper(t)
			sk1 := capKeeper.ScopeToModule(banktypes.ModuleName)
			capKeeper.InitializeAndSeal(ctx)
			result := &sys{ctx, capKeeper, sk1}
			return gopter.NewGenResult(result, gopter.NoShrinker)
		},
		GenCommandFunc: func(state commands.State) gopter.Gen {
			return gopterGen.OneGenOf(genNewCommand)
		},
	}

}

func TestGopterCommand(t *testing.T) {
	parameters := gopter.DefaultTestParametersWithSeed(1234) // Example should generate reproducible results, otherwise DefaultTestParameters() will suffice

	properties := gopter.NewProperties(parameters)

	properties.Property("circular buffer", commands.Prop(cbCommands(t)))

	properties.TestingRun(t)
}
