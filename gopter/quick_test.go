package keeper_test

import (
	"fmt"
	"testing"
	"testing/quick"

	"github.com/tendermint/tendermint/libs/log"

	"github.com/stretchr/testify/require"
	tmproto "github.com/tendermint/tendermint/proto/tendermint/types"
	dbm "github.com/tendermint/tm-db"

	"github.com/leanovate/gopter"
	gopterGen "github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"

	"github.com/cosmos/cosmos-sdk/codec"
	"github.com/cosmos/cosmos-sdk/store"
	storetypes "github.com/cosmos/cosmos-sdk/store/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
	banktypes "github.com/cosmos/cosmos-sdk/x/bank/types"
	"github.com/cosmos/cosmos-sdk/x/capability/keeper"
)

// initialize the capability keeper
func initKeeper(t *testing.T) (sdk.Context, *keeper.Keeper) {
	cdcLegacy := codec.NewLegacyAmino()
	cdc := codec.NewAminoCodec(cdcLegacy)
	db := dbm.NewMemDB()
	cms := store.NewCommitMultiStore(db)
	key := sdk.NewKVStoreKey("hello")
	memkey := storetypes.NewMemoryStoreKey("memhello")

	// create new keeper so we can define custom scoping before init and seal
	keeper := keeper.NewKeeper(cdc, key, memkey)

	// mount stores, initialize and seal
	cms.MountStoreWithDB(key, sdk.StoreTypeIAVL, db)
	cms.MountStoreWithDB(memkey, sdk.StoreTypeMemory, nil)
	require.NoError(t, cms.LoadLatestVersion())
	ctx := sdk.NewContext(cms, tmproto.Header{Height: 1}, false, log.NewNopLogger())

	return ctx, keeper
}

// restrict a uint8 to a range
func normalize(event uint8, max int) int {
	return int(event) % max
}

// event. use simple uint8 fields. EventType is the method to call (eg. 0 for NewCapability, 1 for GetCapability, etc)
// and Name is the capability name (will be mapped to a string)
type ocapEvent struct {
	EventType uint8
	Name      uint8
}

// for each ocap, get the owners, and ensure the owning module can fetch the ocap by name
func checkGet(ctx sdk.Context, globalKeeper *keeper.Keeper, sk keeper.ScopedKeeper) bool {
	latestIdx := globalKeeper.GetLatestIndex(ctx)
	fmt.Println("ITERATING THROUGH", latestIdx)
	for i := uint64(0); i < latestIdx; i++ {

		owners, ok := globalKeeper.GetOwners(ctx, i)
		if !ok {
			return false
		}

		fmt.Println("owner of", i)
		for _, o := range owners.Owners {
			fmt.Println("...", o.Name)
			//module := o.Module // just one module for now
			name := o.Name
			_, ok := sk.GetCapability(ctx, name)
			if !ok {
				fmt.Println("FAIL!")
				return false
			}
		}
	}
	return true
}

// execute some events by called the methods on scopedKeeper
func executeEvents(ctx sdk.Context, globalKeeper *keeper.Keeper, scopedKeeper keeper.ScopedKeeper, events []ocapEvent) bool {
	for _, ev := range events {
		eventType := normalize(ev.EventType, 2)
		nameIdx := normalize(ev.Name, 5)
		name := string([]byte{65 + byte(nameIdx)})

		sk := scopedKeeper
		switch eventType {
		case 0:
			sk.NewCapability(ctx, name)
		case 1:
			sk.GetCapability(ctx, name)
		}
		if !checkGet(ctx, globalKeeper, sk) {
			return false
		}
	}

	return true
}

// manual test
func TestNewCap(t *testing.T) {
	ctx, keeper := initKeeper(t)
	sk1 := keeper.ScopeToModule(banktypes.ModuleName)
	keeper.InitializeAndSeal(ctx)

	// create a new capability
	sk1.NewCapability(ctx, "transfer")
	ok := checkGet(ctx, keeper, sk1)
	require.True(t, ok)

	// create another one. since this will call GetCapability,
	// it will accidentally wipe the first one and checkGet will fail!
	sk1.NewCapability(ctx, "transfer2")
	ok = checkGet(ctx, keeper, sk1)
	require.True(t, ok)
}

// test using testing/quick. doesn't do shrinking, just finds a sequence that violates.
func TestQuick(t *testing.T) {

	f := func(events []ocapEvent) bool {
		ctx, capKeeper := initKeeper(t)
		sk1 := capKeeper.ScopeToModule(banktypes.ModuleName)
		capKeeper.InitializeAndSeal(ctx)

		r := executeEvents(ctx, capKeeper, sk1, events)
		if !r {
			fmt.Println("TRACE")
			for _, ev := range events {
				fmt.Println("event", normalize(ev.EventType, 2), normalize(ev.Name, 5))
			}
		}
		return r
	}
	err := quick.Check(f, nil)
	require.NoError(t, err)
}

// test using gopter. does shrinking but uses same mechanisms for execution as testing/quick.
// not aware of distinct commands.
func TestGopterBasic(t *testing.T) {

	f := func(events []ocapEvent) bool {

		ctx, capKeeper := initKeeper(t)
		sk1 := capKeeper.ScopeToModule(banktypes.ModuleName)
		capKeeper.InitializeAndSeal(ctx)
		r := executeEvents(ctx, capKeeper, sk1, events)
		if !r {
			fmt.Println("TRACE")
			for _, ev := range events {
				fmt.Println("event", normalize(ev.EventType, 2), normalize(ev.Name, 5))
			}
		}
		return r
	}

	properties := gopter.NewProperties(nil)

	// generater for events. an ocapEvent is just two uint8s
	gen := gopter.DeriveGen(
		func(typ uint8, name uint8) ocapEvent {
			return ocapEvent{typ, name}
		},
		func(o ocapEvent) (uint8, uint8) {
			return o.EventType, o.Name
		},
		gopterGen.UInt8(),
		gopterGen.UInt8(),
	)
	gen = gopterGen.SliceOf(gen)

	properties.Property("squared is equal to value", prop.ForAll(f, gen))

	properties.TestingRun(t)
}
