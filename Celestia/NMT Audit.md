# NMT Audit summary

The audit process was comprised of three parts:

1. **Specification overview**
   - NMT spec
   - Wrapper spec
2. **Code review**
   - NMT spec
   - Wrapper spec
3. **Generation of formal specification using Quint**

## Specification overview

- NMT specification overview:
  - Checking the alignment between the specification, underlying documents (Lazy Ledger) and the code comments
  - Checking the clarity of the documentation
  - Issues: audit [IF-CELESTIA-01](../findings/IF-CELESTIA-01.md), [IF-CELESTIA-02](../findings/IF-CELESTIA-02.md), [IF-CELESTIA-05](../findings/IF-CELESTIA-05.md), [IF-CELESTIA-11](../findings/IF-CELESTIA-11.md)([PR](https://github.com/celestiaorg/nmt/pull/134))
- Wrapper specification overview
  - Checking the alignment between the specification and the code comments
  - Checking the clarity of the documentation

## Code review

- Manual code review (with the help of tools like semgrep and CodeQl):
  - Best coding practices
    - Issues: [IF-CELESTIA-08](../findings/IF-CELESTIA-08.md), [IF-CELESTIA-09](../findings/IF-CELESTIA-09.md), [IF-CELESTIA-10](../findings/IF-CELESTIA-10.md), [IF-CELESTIA-12](../findings/IF-CELESTIA-12.md), [IF-CELESTIA-16](../findings/IF-CELESTIA-16.md)
  - Inspecting code logic and alignment with specification and comments
    - Issues: [IF-CELESTIA-03](../findings/IF-CELESTIA-03.md), [IF-CELESTIA-04](../findings/IF-CELESTIA-04.md), [IF-CELESTIA-06](../findings/IF-CELESTIA-06.md), [IF-CELESTIA-17](../findings/IF-CELESTIA-17.md)
  - Analyzing edge cases and searching for flaws
    - Nmt functions
      - Empty tree case
      - Tree with one namespace (special case with ParityNamespace)
      - Tree with a different namespace at the very beginning or the very end (special case with ParityNamespace)
    - Proof functions
      - Empty proof
        - Issue: [IF-CELESTIA-13](../findings/IF-CELESTIA-13.md)
  - Invalid data input
    - Corrupted namespace id and data
      - Wrong data or namespace id size
        - Issues: [IF-CELESTIA-14](../findings/IF-CELESTIA-14.md), [IF-CELESTIA-18](../findings/IF-CELESTIA-18.md)([PR](https://github.com/celestiaorg/nmt/pull/156))
      - Wrong ordering of namespace id
        - Issue: [IF-CELESTIA-07](../findings/IF-CELESTIA-07.md)
    - Corrupted proofs
      - Issue: [IF-CELESTIA-20](../findings/IF-CELESTIA-20.md)
  - Review of tests
    - Analyzing test cases to analyze coverage
      - Issues: [IF-CELESTIA-15](../findings/IF-CELESTIA-15.md), [IF-CELESTIA-19](../findings/IF-CELESTIA-19.md), [PR](https://github.com/celestiaorg/nmt/pull/149)
    - Debugging tests

## Formal Model in Quint

- Generating a formal model with Quint for the following NMT functionalities ([PR](https://github.com/celestiaorg/nmt/pull/163))
  - Generating Inclusion Proofs
  - Verifying Inclusion Proofs
- Using the generated specification to create simulation tests (resulting in the mentioned issue [IF-CELESTIA-20](../findings/IF-CELESTIA-20.md))
  - Happy path tests
  - Edge cases tests
