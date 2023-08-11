# Audit overview


## The Project

In May 2021, Injective engaged Informal Systems to conduct a security audit
over the documentation and the current state of the implementation of
*Injective Protocol*: a Cosmos-backed decentralized derivatives trading
platform. The agreed-upon workplan consisted of two steps:

### Milestone 1: Reviewing spot markets

The focus of this milestone was to review the code that implements exchange
in the spot markets. As spot markets are relatively simple, we agreed that
it was a good starting point. The input to this milestone was: documentation
on Notion, code walkthrough, the codebase in the private github repository
called `injective-core`. Deliverables include open issues that describe
functional and security bugs as well as TLA+ specifications, which can
be used for model-based testing.

In this milestone, we mainly focused on the audit of the `exchange` module.

### Milestone 2: Reviewing derivative markets 

The implementation of the derivative markets is more sophisticated in
comparison to the spot markets. The input to this milestone was: documentation
on Notion, the codebase in the private github repository called
`injective-core`. Deliverables include open issues that describe functional and
security bugs as well as TLA+ specifications, which can be used for model-based
testing.

In this milestone, we mainly focused on the audit of the modules: `exchange`,
`oracle`, and `insurance`.

## Scope of this report

This report covers the audit in the framework of Milestones 1-2 that was
conducted May 11 through June 14, 2021 by Informal Systems under the lead of
Igor Konnov, with the support of Zarko Milosevic. The team spent 3 person-weeks
on the audit.

As the codebase spans over 38 KLOC of Golang code, we could not perform an
exhaustive audit of the whole codebase. Rather we have identified potential
problems in the code and tried to trigger critical errors in the system.

## Conducted work

Starting May 11, the Informal Systems team conducted an audit of the existing
documentation and code in the [project
directory](https://github.com/InjectiveLabs/injective-core) in the Cosmos
repository of hash
[4dac628e](https://github.com/InjectiveLabs/injective-core/commit/4dac628eb1d08f4d66685e9f228f6ff53e9197c9). The Injective Labs team was resolving issues
that were blocking our further progress. Hence, we continued with more
recent versions of the development branch.

The most important issues we documented in the findings which are part of this
report, and as issues on the Injective Labs GitHub repository. A detailed list
can be found in the [Findings](./6-findings-summary.md).



As we quickly found that the general code quality was high and the Injective
Labs team tested their code on regular basis, we changed our auditing approach
to model-based testing, which was backed by a symbolic model checker.  To this
end, we have designed high-level specifications of spot markets and derivative
markets in TLA+, by following the English specifications that were provided by
Injective Labs. Importantly, our TLA+ specifications do not focus on complete
functional correctness. Rather, we used them to drive the system into a
potentially problematic state that we could manually inspect, in order to
trigger bugs in the system.

## Findings

We have found that Injective Protocol is written with attention to details.
Large parts of the codebase contain all necessary validation tests and do not
let an attacker to easily exploit overflows, replay previously recorded
transactions or perform timing attacks. As a result, our straightforward
attempts to attack the system did not succeed.

As we switched to semi-automated model-based testing, we found issues with the
command-line interface of the Injective Protocol, **all resolved**:

 - [IF-INJECTIVE-01](./IF-INJECTIVE-01.md),

 - [IF-INJECTIVE-04](./IF-INJECTIVE-04.md),

 - [IF-INJECTIVE-05](./IF-INJECTIVE-05.md),

 - [IF-INJECTIVE-06](./IF-INJECTIVE-06.md),

 - [IF-INJECTIVE-09](./IF-INJECTIVE-09.md).

None of these issues is severe, as they only affected the client interface. The
main reason for the team paying less attention to CLI is that they are testing
their system by running end-to-end integration tests (that do not use CLI) as
well as manual testing via the web interface. The Injective Labs team was
surprisingly responsive in fixing the discovered issues. Usually, they fixed
issues in less than 1 hour after receiving a report on GitHub and the Discord
channel. Hence, although CLI issues slightly impeded our progress, they did not
block us. 

By code inspection, we have found that Injective Protocol implements reach
functionality in `abci.go:BeginBlocker` and `abci.go:EndBlocker`. While errors
in Cosmos transactions are automatically recovered by the Cosmos framework, by
rolling back an offending transaction, errors in `BeginBlock` and `EndBlock`
are not automatically recovered. Every such an error results in halting the
consensus engine, which effectively means that all validators would have to
patch the code and to coordinate in restarting the blockchain. We have
documented this potential issue in [IF-INJECTIVE-12](./IF-INJECTIVE-12.md). The
team has confirmed that this indeed a potential severe issue that requires
careful redesign of the code. Later, we indeed found attack vectors
[IF-INJECTIVE-10](./IF-INJECTIVE-10.md) and
[IF-INJECTIVE-11](./IF-INJECTIVE-11.md) that exploited this issue. We believe
that these are only two instances of the general issue
[IF-INJECTIVE-12](./IF-INJECTIVE-12.md).  Hence, the issues
[IF-INJECTIVE-10](./IF-INJECTIVE-10.md),
[IF-INJECTIVE-11](./IF-INJECTIVE-11.md), and
[IF-INJECTIVE-12](./IF-INJECTIVE-12.md) are the most severe.  We recommend
designing good defense mechanisms against them. Both issues 10 and 11 highlight
interesting sources of errors, to which the team should pay further attention:

 - [IF-INJECTIVE-10](./IF-INJECTIVE-10.md) was triggered after market expiration,
    which could potentially last for weeks or months in production.
    Interestingly, the user had only to launch a market and wait, without
    performing any trading activity. **Resolved**.

 - [IF-INJECTIVE-11](./IF-INJECTIVE-11.md) was triggered by corrupt input from
    a price feed. As price feeds are outside of the designer's control,
    we recommended the team to carefully validate and filter price feeds.
    **Resolved**.

Two further issues were less severe, but they could probably result in fraud or
loss of tokens:

 - In issue [IF-INJECTIVE-07](./IF-INJECTIVE-07.md), changing the status of a
   spot market resulted in launching another market instance. **Resolved**.

 - In issue [IF-INJECTIVE-08](./IF-INJECTIVE-08.md), demolishing a spot market
   resulted in outstanding orders (and their tokens) being frozen. **Resolved**.

Finally, we found two non-critical issues:

 - Transactions invoked by CLI contained a hard-coded recipient
    address: [IF-INJECTIVE-02](./IF-INJECTIVE-02.md). **Resolved**.

 - Transaction panic [IF-INJECTIVE-03](./IF-INJECTIVE-03.md). **Resolved**.

*We emphasize that the five severe issues would not be found by the standard
lightweight static analysis or fuzzing. They required knowledge of the source
code and executing carefully crafted sequences of transactions. We do not
consider them as being easily exploitable.*

