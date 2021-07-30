### IF-INJECTIVE-02
## Hard-coded fee recipient in the client code #289

**Status: Resolved**

**Severity**: Low   

**Type**: Protocol, Economics & Implementation

**Difficulty**: Low

Surfaced from Informal Systems audit of hash 4dac628eb1d08f4d66685e9f228f6ff53e9197c9

This is issue has been created for documentation purposes. It has been fixed by the team in 043a2402e59a985400c676dc6d4b6fa1ca85567b after communication on discord.

The client code contained a hard-coded address of the fee recipient: https://github.com/InjectiveLabs/injective-core/blob/4dac628eb1d08f4d66685e9f228f6ff53e9197c9/injective-chain/modules/exchange/client/cli/tx.go#L174-L188

The fix https://github.com/InjectiveLabs/injective-core/commit/043a2402e59a985400c676dc6d4b6fa1ca85567b sets the sender as the fee recipient.
