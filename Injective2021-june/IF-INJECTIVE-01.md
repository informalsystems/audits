### IF-INJECTIVE-01
## CLI interface fails with a stack trace when supplying incorrect arguments #287

**Status: Resolved**

**Severity**: Low   

**Type**: Implementation & Testing

**Difficulty**: Low

Surfaced from Informal Systems audit at hash 4dac628eb1d08f4d66685e9f228f6ff53e9197c9.

**Observed behavior**

Here is an example for "query exchange deposits":

```sh
~/go/bin/injectived query exchange deposits
panic: runtime error: index out of range [1] with length 0
...
```

**Expected behavior**

An error message printed on stderr, without a stack trace. For instance, here is how the bank module reacts on the wrong number of arguments:

```sh
~/go/bin/injectived query bank balances
Error: accepts 1 arg(s), received 0
Usage:
  injectived query bank balances [address] [flags]
...
```

**Version**

Running `injectived` that was compiled from 4dac628eb1d08f4d66685e9f228f6ff53e9197c9.

