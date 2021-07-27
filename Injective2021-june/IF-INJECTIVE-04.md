### IF-INJECTIVE-04
## NPE when launching an instant spot market #295

**Status: Resolved**

**Severity**: Low   

**Type**: Implementation & Testing

**Difficulty**: Low

Surfaced from Informal Systems audit of hash 1e4d2914b3ae616b98b05fb70eb487550fc99ed7

This is a follow up of #291. The recent fix in ba9f2eb7a76dfd81a9d1f74970597085e2253357 introduced NPE in the client.
run the following command in the standard setup, as done with ./setup.sh:

```sh
injectived tx exchange instant-spot-market-launch INJ/INJ inj inj \
  --from=genesis --chain-id=888 --keyring-backend=file
Enter keyring passphrase:
panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x5fb461]

 ...
```

As far as I can tell, the code in `injective-chain/modules/exchange/client/cli/tx.go` fails to add the message fields `MinPriceTickSize` and `MinQuantityTickSize`, which results in an NPE later.
