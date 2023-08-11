# Recommendations 

This section aggregates all the recommendations made during the audit. Short-term
recommendations address the immediate causes of issues. Long-term recommendations
pertain to the development process and long-term design goals.

## Short term

- **Test for non-standard scenarios.** Issues
  [IF-INJECTIVE-07](./IF-INJECTIVE-07.md) and
  [IF-INJECTIVE-08](./IF-INJECTIVE-08.md) were probably outside of the standard
  scenarios of a testing engineer, as they are rarely used features.

- **Test for time-related issues.** As exemplified by
  [IF-INJECTIVE-10](./IF-INJECTIVE-10.md), functional tests are not sufficient.
  Injective Protocol is using timeouts and hence it should be tested with
  timeouts in mind.

- **Avoid hard-coded addresses.** As exemplified by
  [IF-INJECTIVE-02](./IF-INJECTIVE-02.md).

- **Add tests for CLI.** As demonstrated by issues
 [IF-INJECTIVE-01](./IF-INJECTIVE-01.md),
 [IF-INJECTIVE-04](./IF-INJECTIVE-04.md),
 [IF-INJECTIVE-05](./IF-INJECTIVE-05.md),
 [IF-INJECTIVE-06](./IF-INJECTIVE-06.md),
 [IF-INJECTIVE-09](./IF-INJECTIVE-09.md).

## Long term

- **ABCI methods.** As stressed in [IF-INJECTIVE-12](./IF-INJECTIVE-12.md) and
  exemplified by [IF-INJECTIVE-10](./IF-INJECTIVE-10.md), the system should be
  re-designed in a way that does not halt the consensus engine, if a panic
  occurs in the code that is triggered by the methods `abci.go:BeginBlock` and
  `abci.go:EndBlock`.

- **Price oracles.** As exemplified by [IF-INJECTIVE-11](./IF-INJECTIVE-11.md),
  the team should pay attention to the interaction with the price oracles, as
  they are outside of the designer's control. Thus, price oracles may be used
  by an attacker or they can accidentally feed corrupt data into the system.
  We recommend receiving price values from `3f + 1` feeds and filtering out
  the `f` smallest and the `f` largest values, while averaging the rest.

