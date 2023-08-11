# Coverage

Informal Systems manually reviewed the relevant components in
the [IBC directory of the Cosmos-SDK](https://github.com/cosmos/cosmos-sdk/tree/master/x/ibc)
starting at commit hash [6cbbe0d](https://github.com/cosmos/cosmos-sdk/commit/6cbbe0d4ef90f886dfc356979b89979ddfcd00d8). 
Manual review resulted in findings [IF-IBC-001](./IF-IBC-01.md) through
[IF-IBC-012](./IF-IBC-12.md). We also did a preliminary model-based testing of the ICS-20 token transfer app
based on the TLA+ specification of the ICS20 that resulted in [IF-IBC-13](./IF-IBC-13.md) and
[IF-IBC-14](./IF-IBC-14.md). This audit focused on implementation and 
specification of token transfer application (ICS20), channels and packets (ICS04), connections (ICS03),
clients (ICS02 and ICS07), and the relayer specification (ICS18), but the relayer implementation was not in the scope.

A non-exhaustive list of some approaches taken, and their results include:

- Capturing pre and post conditions of the core IBC handlers helped us identify ambiguities and bugs in 
the IBC specifications that could lead to invalid usage of IBC and insecure IBC implementations ([IF-IBC-01](./IF-IBC-01.md))
- Carefully reviewing (manually) the code and the specifications led to [IF-IBC-06](./IF-IBC-06.md)
  and [IF-IBC-07](./IF-IBC-07.md).
- Understanding execution model and implementation of object capabilities in SDK helped us identify the following
  issues: [IF-IBC-02](./IF-IBC-02.md), [IF-IBC-09](./IF-IBC-09.md), [IF-IBC-10](./IF-IBC-10.md) and
  [IF-IBC-12](./IF-IBC-12.md).
- Analysing handler executions under the worst case scenarios (allowed by the model) confirmed that,
  besides [IF-IBC-08](./IF-IBC-08.md) and [IF-IBC-11](./IF-IBC-11.md), which were addressed in the meantime,
  protocols are safe under the threat model assumed. Note that ensuring protocol liveness heavily depends on the 
  correct relayer implementations, and it was left off the scope of this audit.
- Using model based testing ([IF-IBC-13](./IF-IBC-13.md)), where tests are automatically generated using Apalache model checker
from TLA+ specification, surfaced [IF-IBC-14](./IF-IBC-14.md), and suggests that
it might be useful to expand this exercise further in the future.
- Finally, carefully reading specifications in order to understand expected behaviour led to several findings 
that suggest possible improvements in making properties more clear ([IF-IBC-03](./IF-IBC-03.md)), relayer
  specification more complete ([IF-IBC-04](./IF-IBC-04.md)) and restructuring of ICS02 in order to simplify onboarding
  of IBC adopters ([IF-IBC-05](./IF-IBC-05.md)).


