# Code review of the payment module

- code is not well structured, most of the methods are in `x/payment/types` not really grouped based on functionality

## Code quality
- [x/payment/payfordata.go only used for testing](https://github.com/informalsystems/audit-celestia/issues/3)
- [LegacyMsg in payment module deprecated in favor of Msg Services](https://github.com/informalsystems/audit-celestia/issues/1)

## Transaction Lifecycle

### CheckTx

> *Note:* Although the desired outcome is only for `MsgWirePayForData` messages to be submitted to the application via `CheckTx`, there is nothing stopping `MsgPayForData` messages to be in the mempool. 

| Message | Source code | Brief description | UTs | Issues found | 
| ------- | ----------- | ----------------- | --- | ------------ |
| `MsgWirePayForData` | [ValidateBasic](https://github.com/celestiaorg/celestia-app/blob/9e01bd307d428fffcd1a8a66e0d97719a3e83d90/x/payment/types/wirepayfordata.go#L87) | Stateless checks of `MsgWirePayForData`. | [TestWirePayForData_ValidateBasic](https://github.com/celestiaorg/celestia-app/blob/9e01bd307d428fffcd1a8a66e0d97719a3e83d90/x/payment/types/wirepayfordata_test.go#L10) | - [CreateCommitment could be expensive for CheckTx](https://github.com/informalsystems/audit-celestia/issues/6) <br /> - [WirePayForData with empty Message](https://github.com/informalsystems/audit-celestia/issues/8) |
| MsgPayForData | See [DeliverTx](#delivertx) section below | | | |

#### CreateCommitment

- [Comment of NextHighestPowerOf2 is inaccurate](https://github.com/informalsystems/audit-celestia/issues/4)
- [Too many namespace prefixes per share?](https://github.com/informalsystems/audit-celestia/issues/5)

```golang
func CreateCommitment(k uint64, namespace, message []byte) {
    // ...
    shares := msg.SplitIntoShares().RawShares()
    // SplitIntoShares() => list of shares: (nid|len|partial-message1, nid), (nid|len|partial-message2, nid), ...
    // .RawShares() => [nid|len|partial-message1, nid|len|partial-message2 ... ]
    if uint64(len(shares)) > (k*k)-1 {
		return nil, fmt.Errorf("message size exceeds max shares for square size %d: max %d taken %d", k, (k*k)-1, len(shares))
	}
    // TODO this check assumes that only this message gets in the square (no txs or evidence)

    // split shares into leafSets, each of size k or a power of two < k
    //  - create an ErasuredNamespacedMerkleTree subtree for every set in leafSets
    //      - for every leaf in set, nsLeaf=namespace|leaf is added as a leaf in the subtree
    //      via ErasuredNamespacedMerkleTree.Push(nsLeaf)
    //          - prefix share with another namespace !!!
    //      - compute root of subtree
    //  - compute hash of all the subtree roots 
    return merkle.HashFromByteSlices(subTreeRoots)
}

func (msgs Messages) SplitIntoShares() NamespacedShares {
    shares := make([]NamespacedShare, 0)
    for _, m := range msgs.MessagesList {
        rawData, err := m.MarshalDelimited()
        // rawData: len | data
        shares = AppendToShares(shares, m.NamespaceID, rawData)
    }
    return shares
}

func AppendToShares(shares []NamespacedShare, nid namespace.ID, rawData []byte) []NamespacedShare {
    if len(rawData) <= 248 {
        // rawShare: nid | len | data
        // paddedShare: zeroPadIfNecessary up to 256
        share := NamespacedShare{paddedShare, nid}
        // !!! a share has the nid twice !!!
        shares = append(shares, share)
    } else {
        shares = append(shares, splitMessage(rawData, nid)...)
	}
	return shares
}

// splitMessage breaks the data in a message into the minimum number of
// namespaced shares
func splitMessage(rawData []byte, nid namespace.ID) NamespacedShares {
    // result: (nid|len|partialData1, nid), (nid|len|partialData2, nid), ...
}
```

### PrepareProposal

| Method | Invoked by | Brief description | UTs | Issues found | 
| ------ | ---------- | ----------------- | --- | ------------ |
| [parsedTxs()](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/app/parse_txs.go#L63) | `PrepareProposal` | Parse TXs in proposed block. | [estimate_square_size_test.go](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/app/estimate_square_size_test.go) | - [MsgWirePayForData messages are validate twice by the proposer](https://github.com/informalsystems/audit-celestia/issues/10) |
| [estimateSquareSize()](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/app/estimate_square_size.go#L101) | `PrepareProposal` | Estimate square size using the data in the proposed block. | [Test_estimateSquareSize](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/app/estimate_square_size_test.go#L18) | - [nextPowerOfTwo vs. NextHigherPowerOf2](https://github.com/informalsystems/audit-celestia/issues/15) |
| [rawShareCount()](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/app/estimate_square_size.go#L145) | `estimateSquareSize` | Calculates the number of shares needed by the block data. | NA | - [[Optimization] MsgSharesUsed requires remainder operation](https://github.com/informalsystems/audit-celestia/issues/11) <br /> - [The number of TX shares is incremented twice](https://github.com/informalsystems/audit-celestia/issues/12) <br /> - [Unit length missing from estimating txBytes in rawShareCount](https://github.com/informalsystems/audit-celestia/issues/13) <br /> - [Number of share estimated by rawShareCount is inaccurate](https://github.com/informalsystems/audit-celestia/issues/14) |
| [FitsInSquare](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/shares/non_interactive_defaults.go#L7) | `estimateSquareSize` | Uses the non interactive default rules to see if messages of some lengths will fit in a square of squareSize starting at share index cursor. | [TestFitsInSquare](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/shares/non_interactive_defaults_test.go#L47) | - [FitsInSquare is incorrect for edge case](https://github.com/informalsystems/audit-celestia/issues/16) |
| [prune](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/app/estimate_square_size.go#L21) | `PrepareProposal` | Removes txs until the set of txs will fit in the square. | [Test_pruning](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/app/estimate_square_size_test.go#L68) | - [Inconsistency while pruning compact shares](https://github.com/informalsystems/audit-celestia/issues/22) <br> - [Redundancy in PrepareProposal](https://github.com/informalsystems/audit-celestia/issues/27) |
| [malleateTxs](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/app/malleate_txs.go#L14) | `PrepareProposal` | Process any MsgWirePayForData transactions into MsgPayForData and their respective messages. | NA | NA |
| [malleate](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/app/malleate_txs.go#L86) | `malleateTxs` | Split `MsgWirePayForData` txs into `MsgPayForData` txs and data. | NA | - [Complex logic for estimating the square size](https://github.com/informalsystems/audit-celestia/issues/24) |
| [ProcessWirePayForData](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/x/payment/types/wirepayfordata.go#L263) | `malleate` | Parses the MsgWirePayForData to produce the components needed to create a single MsgPayForData. | [TestProcessMessage](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/x/payment/types/payfordata_test.go#L259) | NA |
| [calculateCompactShareCount](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/app/estimate_square_size.go#L68) | `malleateTxs` | calculates the exact number of compact shares used | [Test_calculateCompactShareCount](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/app/estimate_square_size_test.go#L143) | - [ShareIndex offset in calculateCompactShareCount](https://github.com/informalsystems/audit-celestia/issues/25) | 
| [NewCompactShareSplitter](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/shares/split_compact_shares.go#L25) | `calculateCompactShareCount` | Creates a CompactShareSplitter. | [TestCompactShareWriter](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/shares/compact_shares_test.go#L15) | NA |
| [Split](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/shares/share_splitting.go#L25) | `PrepareProposal` | converts block data into encoded shares | NA | - [SparseShareSplitter writer can be simplified](https://github.com/informalsystems/audit-celestia/issues/28) |
| [ExtendShares](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/da/data_availability_header.go#L52) | `PrepareProposal` | Erasure the data square. Relies on the [rsmt2d](https://github.com/celestiaorg/rsmt2d) library. | [TestExtendShares](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/da/data_availability_header_test.go#L78) | NA |
| [NewDataAvailabilityHeader](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/da/data_availability_header.go#L39) | `PrepareProposal` | Generates a `DataAvailability` header using the provided square size and shares. | [TestNewDataAvailabilityHeader](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/da/data_availability_header_test.go#L38) | NA |

### ProcessProposal

| Method | Invoked by | Brief description | UTs | Issues found | 
| ------ | ---------- | ----------------- | --- | ------------ |
| [ProcessProposal](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/app/process_proposal.go#L23) | ABCI++ | | [TestMessageInclusionCheck](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/app/test/process_proposal_test.go#L24) | - [Minor: Inconsistency re. number of messages in PFDs](https://github.com/informalsystems/audit-celestia/issues/29) <br /> - [Commitments checked only in ProcessProposal](https://github.com/informalsystems/audit-celestia/issues/30) |
| [Split](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/shares/share_splitting.go#L25) | `ProcessProposal` | converts block data into encoded shares | NA | See [PrepareProposal](#prepareproposal) |
| [NewDataAvailabilityHeader](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/da/data_availability_header.go#L39) | `ProcessProposal` | Generates a `DataAvailability` header using the provided square size and shares. | [TestNewDataAvailabilityHeader](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/da/data_availability_header_test.go#L38) | See [PrepareProposal](#prepareproposal) |
| [GetCommit](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/inclusion/get_commit.go#L10) | `ProcessProposal` | Get PFD commitment | NA | NA |
| [calculateCommitPaths](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/inclusion/paths.go#L16) | `GetCommit` | Calculates all of the paths to subtree roots needed to create the commitment for a given message. | [Test_calculateSubTreeRootCoordinates](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/inclusion/paths_test.go#L10) | NA | 
| [getSubTreeRoot](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/inclusion/nmt_caching.go#L120) | `GetCommit` | Traverses the nmt of the selected row and returns the subtree root. | [TestEDSSubRootCacher](https://github.com/celestiaorg/celestia-app/blob/e088d61fcb6579b4bc797deefd2ceff7601aa079/pkg/inclusion/nmt_caching_test.go#L117) | NA |


### DeliverTx

> *Note:* Only `MsgPayForData` are delivered to the payment module.

| Message | Source code | Brief description | UTs | Issues found | 
| ------- | ----------- | ----------------- | --- | ------------ |
| MsgPayForData | [ValidateBasic](https://github.com/celestiaorg/celestia-app/blob/9e01bd307d428fffcd1a8a66e0d97719a3e83d90/x/payment/types/payfordata.go#L39) | Stateless checks of `MsgPayForData`. | [TestValidateBasic](https://github.com/celestiaorg/celestia-app/blob/9e01bd307d428fffcd1a8a66e0d97719a3e83d90/x/payment/types/payfordata_test.go#L318) | - [MsgPayForData.ValidateBasic doesn't invalidate reserved namespaces](https://github.com/informalsystems/audit-celestia/issues/2) |
| MsgPayForData | [MsgServer.PayForData](https://github.com/celestiaorg/celestia-app/blob/9e01bd307d428fffcd1a8a66e0d97719a3e83d90/x/payment/keeper/keeper.go#L32) | Execute `MsgPayForData`: Consume `msg.MessageSize` amount of gas. | [TestPayForDataGas](https://github.com/celestiaorg/celestia-app/blob/9e01bd307d428fffcd1a8a66e0d97719a3e83d90/x/payment/keeper/gas_test.go#L13) | None |
