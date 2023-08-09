# Collaboration scope
### Phase 1
The first half of the collaboration focused on formally model and check the Proof-of-Stake system of Namada. Starting from an incomplete English specification, we have:
* First transform the English spec into a pseudocode model, filling up any gap that the English spec may had.
* Define state invariants.
* Model the protocol and the invariants in TLA+ and use Apalache and Apalache cloud to check the invariants.
* We also did some MBT, but the code was not ready for it.

### Phase 2
The second half of the collaboration focused on designing a new feature: adding fast relegation to Proof-of-Stake system of Namada. We took the following steps:
* Design the new feature using the pseudocode model as playground.
* We then decided to move from a non-executable spec (pseudocode-based) to an executable Quint spec: with relegation the specification was getting too complex to maintain and reason about.
* Use Quint’s simulator to check invariants.

### Artifacts
We have produced several artifacts:
* [Pseudocode model without relegation](https://github.com/informalsystems/partnership-heliax/blob/trunk/2022/Q4/artifacts/PoS-pseudocode/PoS-model.md)
* [TLA+ model without relegation](https://github.com/informalsystems/partnership-heliax/tree/trunk/2023/Q1/artifacts/PoS-tla)
* [Blogpost](https://informal.systems/blog/checking-namada-proof-of-stake)
* [Pseudocode model with relegation](https://github.com/informalsystems/partnership-heliax/blob/manuel/redelegation-q1/2023/Q1/artifacts/PoS-pseudocode/PoS-model-redelegation.md)
* [Quint spec without relegation](https://github.com/informalsystems/partnership-heliax/tree/trunk/2023/Q2/artifacts/PoS-quint)
* [Quint spec with redelegation](https://github.com/informalsystems/partnership-heliax/tree/manuel/quint-redelegation/2023/Q2/artifacts/PoS-quint)

### Methods used
To summarize, the methods we have used are:
* Formal modeling
* Protocol analysis
* Formal verification
* Protocol design (which include protocol reconstruction)
