# Audit overview

In December 2019, the Interchain Foundation engaged Informal Systems to take leadership
over the implementation of the Inter-Blockchain Communication (IBC) Protocol in
[Rust](https://github.com/informalsystems/ibc-rs)
and to formally specify the
[protocol in TLA+](https://github.com/informalsystems/ibc-rs/tree/master/docs/spec). Starting October 26 2020, the 
Informal Systems team conducted an internal audit of the existing IBC specification in English and implementation in Go.
The audit was conducted over the course of eight person-weeks with four research engineers. Note that engineers involved
in the audit were primarily those that had not worked on the Rust and TLA+ IBC deliverables;
that said, some members of the audit team already had a good understanding of the IBC protocols and familiarity
with the SDK code base.

We audited the relevant components in
the [IBC directory of the Cosmos-SDK](https://github.com/cosmos/cosmos-sdk/tree/master/x/ibc), working from
commit hash [6cbbe0d](https://github.com/cosmos/cosmos-sdk/commit/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8), 
and the corresponding [IBC specification](https://github.com/cosmos/ics),
working from commit hash
[7e6978a](https://github.com/cosmos/cosmos-sdk/commit/7e6978ae551bbed439c69178184dea0a25d0e747). The `github.com/cosmos/relayer`
repository, which implements the IBC relayer in Golang, was not in the scope.
Throughout the process, we worked closely with the Interchain GmbH team in order to
continuously integrate the outputs of the audit, so the code and the specification were moving targets during the audit.
We want also to note that many of our recommendations were already addressed in the meantime 
([SDK#8006](https://github.com/cosmos/cosmos-sdk/pull/8006), [SDK#7993](https://github.com/cosmos/cosmos-sdk/pull/7993),
[SDK#8145](https://github.com/cosmos/cosmos-sdk/pull/8145), [SDK#8119](https://github.com/cosmos/cosmos-sdk/pull/8119), 
[SDK#7967](https://github.com/cosmos/cosmos-sdk/pull/7967), [SDK#7770](https://github.com/cosmos/cosmos-sdk/pull/7770) 
and [ICS#493](https://github.com/cosmos/ics/pull/493)).

The audit was conducted in a top down approach, starting from the implementation of the token transfer application 
([ICS20](https://github.com/cosmos/ics/tree/master/spec/ics-020-fungible-token-transfer)), 
and moving down the IBC stack analysing the implementations of channels and packets 
([ICS04](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics)), connections 
([ICS03](https://github.com/cosmos/ics/tree/master/spec/ics-003-connection-semantics)) and
clients ([ICS02](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics) and 
[ICS07](https://github.com/cosmos/ics/tree/master/spec/ics-007-tendermint-client)). For each ICS we started by 
thoroughly inspecting the specification; we formalized the protocol by writing 
pre-conditions and post-conditions of the core functions that constitute 
the protocol (see [models](./models) directory). 
We then reviewed the code with a focus on finding
(a) discrepancies between the code and the specification and, (b) possible vulnerabilities.

The audit of the Token Transfer application (ICS20) surfaced several issues:

- [IF-IBC-01](./IF-IBC-01.md), [IF-IBC-02](./IF-IBC-02.md), [IF-IBC-06](./IF-IBC-06.md) and 
  [IF-IBC-07](./IF-IBC-07.md) pointed out the discrepancies between the implementation and 
the specification that might lead to some attack scenarios due to user misunderstanding the specification. 
  Furthermore, it could lead to the insecure (future) implementations of the protocols.
- [IF-IBC-10](./IF-IBC-10.md) captures the protocol/implementation bug related to escrow address collisions
- [IF-IBC-12](./IF-IBC-12.md) points to some poor software practices and lack of proper documentations.
- [IF-IBC-13](./IF-IBC-13.md) and [IF-IBC-14](./IF-IBC-14.md) capture the initial work on model based testing (MBT) of token transfer application, which caught a panic triggered by multi-chain token denominations.

After ICS20, we moved to channels and packets (ICS04). In addition to the imprecise specifications and discrepancies
between the implementations and the specification ([IF-IBC-02](./IF-IBC-02.md)), we realised that the definitions of properties were
imprecise and that they might mislead users, leading to risky scenarios that could result
in loss of funds ([IF-IBC-03](./IF-IBC-03.md)). Furthermore, we identified a protocol/implementation bug whereby
a malicious relayer could prevent the connection and channel handshakes from terminating ([IF-IBC-11](./IF-IBC-11.md)).

In parallel with the audit of the ICS04 implementation, we took a more general look at the object capabilities implementation
in the Cosmos SDK as it is a critical security component. We captured some issues in [IF-IBC-09](./IF-IBC-09.md)
in the context of the IBC port and channel keepers, although it can be seen as a more general issue of the SDK's object capability system.

Apart from [IF-IBC-11](./IF-IBC-11.md), no major issues were found with respect to ICS03. With respect to clients (bottom of the IBC stack),
we found a protocol bug in the Tendermint light client implementation ([IF-IBC-08](./IF-IBC-08.md)), and suggested major restructuring
of ICS02 in [IF-IBC-05](./IF-IBC-05.md) to improve its clarity and rigor.
Furthermore, we reviewed ICS18 (though we haven't carefully reviewed Go implementation of the relayer),
and wrote up our findings in [IF-IBC-04](./IF-IBC-04.md); in short, the relayer logic is significantly underspecified with 
several important points left open, that could lead to wrong implementations.

Considering the importance and security risks of Token Transfer (ICS-20), we have invested some time into
developing [model based tests](./models/ics20/model_based_tests) based on TLA+ specifications. The approach taken is captured
in [IF-IBC-13](./IF-IBC-13.md) and the bug found using MBT is explained in [IF-IBC-14](./IF-IBC-14.md).

Note that two additional aspects of IBC were not covered in this audit. The first is
ICS23 and its implementation. The second is the upgrade logic for connections and channels,
which is not captured in the specification. We recommend the upgrade logic be
captured more clearly in the specification, and that both these aspects of the specification and
code receive further review.

In addition to those major findings, we have created several issues on both 
[cosmos-sdk](https://github.com/cosmos/cosmos-sdk/issues?q=is%3Aissue+Surfaced+from+Informal+Systems+IBC+Audit) and 
[cosmos/ics](https://github.com/cosmos/ics/issues?q=is%3Aissue+Surfaced+from+Informal+Systems+IBC+Audit+) repositories and 
engaged with the team at Interchain Berlin in helping them address the most critical ones.

Overall, our team found the protocol to be well designed and implemented.
However, we anticipate that early IBC adopters may have a hard time correctly navigating through and understanding the
specification, i.e., the specification could benefit from improved clarity and better organisation. Furthermore, 
misunderstanding of the guaranteed properties might lead to insecure implementations and wrong usage. We have made 
several concrete recommendations in this report how this can be improved. At the implementation level, the major issues 
come from the integration of the IBC implementation in the Cosmos SDK framework. This made it hard to understand the 
execution model in which IBC handlers run, the atomicity assumptions of functions and error handling and propagation. 
Furthermore, the implementation of capabilities framework might lead to security issues where a malicious IBC module
could be able to obtain the capability associated with any channel, and send/receive messages on another modules channel.
Although code has pretty good test coverage, our recommendation is to take advantage of the TLA+ 
specifications of the IBC protocol to implement model based tests (MBT) for the complex corner cases of the 
critical components of the stack, following the example demonstrated during the audit. 
Finally, we want to note that although we have found several discrepancies between the code and the specification, 
the code had usually implemented things correctly or took other defensive measures.   

