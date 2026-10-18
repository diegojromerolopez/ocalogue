# US-003: Relations, Unification, and Safety Validation

## Story

As a Datalog engine maintainer, implement immutable relations, unification, comparisons, and rule validation. Enable later evaluator work to consume safe, deterministic domain operations.

## depends_on

- US-001

## Scope

Implement the relation, tuple, substitution, comparison, index, safety, error, and black-box probe modules. Keep the parser and evaluator outside this story. Use immutable OCaml data structures in core modules. Preserve the AST meaning defined by the specification.

Represent all integer values with signed `Int64.t` values. Reject values outside the signed 64-bit range. Preserve deterministic ordering for values, tuples, relations, variables, errors, and JSON fields.

Use a strict dependency DAG. Leaf modules must not import package facades, index modules, or executable entrypoints. Keep each module focused on one responsibility. Ask whether an automated script provides a faster and safer method for structured JSON and AST test data before editing such data manually.

## Required Files

Create or update these exact paths:

- `lib/types.ml` — values, terms, tuples, ordering, and canonical rendering.
- `lib/errors.ml` — public error values, codes, messages, and rendering.
- `lib/relation.ml` — immutable relations, tuple insertion, membership, matching, and scans.
- `lib/relation_index.ml` — persistent one-position and multi-position indexes.
- `lib/unification.ml` — substitutions, bindings, matching, normalization, and application.
- `lib/comparison.ml` — comparison operators and typed comparison evaluation.
- `lib/validation.ml` — atom arity, rule safety, and comparison validation.
- `lib/probe_codec.ml` — JSONL request decoding and response encoding.
- `lib/probe_operations.ml` — probe operation dispatch and result conversion.
- `lib/probe.ml` — callable JSONL stream loop with injectable input and output.
- `lib/dune` — module declarations and library configuration.
- `test/test_types.ml` — value, integer, tuple, and ordering tests.
- `test/test_errors.ml` — error code and rendering tests.
- `test/test_relation.ml` — relation creation, insertion, membership, and arity tests.
- `test/test_relation_index.ml` — persistent index and lookup tests.
- `test/test_unification.ml` — bindings, repeated variables, wildcards, and cycles.
- `test/test_comparison.ml` — equality, inequality, ordering, and invalid types.
- `test/test_validation.ml` — arity, safety, error precedence, and deterministic errors.
- `test/test_probe_codec.ml` — JSON shape, escaping, and response ordering.
- `test/test_probe_operations.ml` — operation boundary tests with in-memory stores.
- `test/test_probe.ml` — JSONL protocol tests with in-memory channels.
- `test/test_us003_blackbox.ml` — process-level probe tests.
- `test/us003-cases.jsonl` — newline-delimited black-box cases.
- `test/dune` — test executable declarations.
- `bin/main.ml` — thin wrapper only when the existing executable requires an update.

## Public Interfaces

Expose immutable, result-based APIs with these capabilities:

- `Types`: construct and compare `Int64.t` values, ground values, terms, and ordered tuples.
- `Relation`: create an empty relation with an arity, create a relation from tuples, insert a tuple, test membership, return cardinality, return arity, match a pattern, scan in canonical order, and return a lookup result.
- `Relation_index`: build persistent indexes for requested positions and perform one-position or multi-position lookup.
- `Unification`: create an empty substitution, bind variables, match terms against ground values, normalize bindings, apply substitutions, and report cyclic bindings.
- `Comparison`: evaluate `Eq`, `Neq`, `Lt`, `Le`, `Gt`, and `Ge` over supported values.
- `Validation`: validate atom arity, rule safety, and comparisons with deterministic error precedence.
- `Probe.run`: read JSONL requests from an input channel and write one JSON response per request to an output channel.

Return domain results through explicit result types. Do not use exceptions as the normal domain result channel.

## Domain Model

Use these AST terms:

- `Var of string`
- `ConstString of string`
- `ConstInt of Int64.t`
- `ConstSymbol of string`
- `Wildcard`

Define a ground value as an immutable value containing a string, symbol, or signed `Int64.t`. Define a tuple as an ordered list of ground values. Permit zero-length tuples and zero-arity relations.

Define a relation as an immutable set of tuples with one fixed arity. Permit an empty relation with a declared arity. Reject every tuple with a different length. Return `ARITY_CONFLICT` and leave the source relation unchanged.

Define a substitution as an immutable map from variable names to terms or ground values. Normalize chained bindings before comparison or application. Do not bind a wildcard. Reject empty variable names. Detect cyclic variable bindings and return `UNIFICATION_FAILURE`.

## Relation Requirements

1. Create an empty relation for every non-negative arity.
2. Create a relation from valid tuples without duplicate tuples.
3. Insert tuples immutably.
4. Reject short and long tuples with `ARITY_CONFLICT`.
5. Preserve the original relation after every failed insertion.
6. Return membership and cardinality results.
7. Match constants by exact type and value.
8. Match variables by binding or existing binding consistency.
9. Match wildcards without adding bindings.
10. Return tuples in canonical deterministic order.
11. Build persistent indexes for requested argument positions.
12. Support one-position and multi-position lookup.
13. Return an empty result for an absent index key.
14. Return no duplicate tuples after repeated insertion.
15. Make indexed results equal to equivalent full-scan results.

## Unification and Comparison Requirements

1. Match symbols case-sensitively.
2. Match strings by exact byte sequence.
3. Match signed integers numerically.
4. Accept repeated variables only when all occurrences agree.
5. Return `UNIFICATION_FAILURE` for conflicting bindings.
6. Never use physical equality for semantic values.
7. Apply substitutions until all bindings are normalized.
8. Evaluate equality and inequality for equal value types.
9. Evaluate numeric ordering for signed `Int64` values.
10. Reject ordering between strings, symbols, or integers.
11. Reject ordering between different value types.
12. Return `INVALID_COMPARISON` for rejected comparisons.
13. Define equality by value, not source spelling.

## Rule Validation Requirements

Validate every rule before evaluation.

1. Collect variables from the head, positive atoms, negated atoms, and comparisons.
2. Require every head variable to occur in a positive relational body atom.
3. Require every negated-atom variable to occur in a positive relational body atom.
4. Require every comparison variable to occur in a positive relational body atom.
5. Allow constants and wildcards without safety bindings.
6. Validate every atom against declared predicate arity.
7. Report predicate, expected arity, and actual arity for arity errors.
8. Report all unsafe variables in sorted name order.
9. Validate errors in this order: arity, safety, comparison.
10. Keep validation independent from parsing and evaluation.

## Public Error Contract

Expose these stable error codes:

- `UNSAFE_VARIABLE`
- `ARITY_CONFLICT`
- `INVALID_COMPARISON`
- `UNIFICATION_FAILURE`
- `INTEGER_OUT_OF_RANGE`

Render textual errors as one line:

`ERROR <CODE>: <message>`

Write successful data to standard output. Write errors to standard error. Return exit status `0` for success, `1` for domain validation or unification errors, `2` for malformed protocol input, and `3` for unexpected internal failures. Do not print backtraces during normal domain failures.

## JSONL Probe Contract

Run the probe with:

`dune exec test/test_us003_blackbox.exe`

Read one JSON object per input line. Write one JSON object per output line. Stop at end of input without an extra response. Use no network socket.

Accept this envelope:

`{"operation":"validate","rule":{...}}`

Support these operations:

- `relation_insert`
- `relation_lookup`
- `unify`
- `compare`
- `validate`

Return success as:

`{"ok":true,"result":...}`

Return domain failure as:

`{"ok":false,"error":{"code":"...","message":"..."}}`

Use field order `ok`, then `result` or `error`. Escape JSON strings correctly. Reject invalid JSON, missing fields, unknown operations, and invalid value shapes with protocol status `2`. Reject unknown fields only when they make a request ambiguous. Keep `bin/main.ml` below 15 lines when it changes, and delegate immediately to a callable library function.

## Scenario and Edge Case Matrix

| Case | Expected result |
|---|---|
| Empty relation with arity 2 | Success; cardinality is 0 |
| Zero-arity relation with empty tuple | Success |
| Correct tuple length | Insert succeeds |
| Short tuple | `ARITY_CONFLICT`; relation remains unchanged |
| Long tuple | `ARITY_CONFLICT`; relation remains unchanged |
| Duplicate insertion | Cardinality increases once |
| Missing index key | Empty result |
| Repeated variable with equal values | Binding succeeds |
| Repeated variable with different values | `UNIFICATION_FAILURE` |
| Wildcard match | Match succeeds without a wildcard binding |
| Empty variable name | Protocol or validation error |
| Minimum signed integer | Accept `-9223372036854775808` |
| Maximum signed integer | Accept `9223372036854775807` |
| Integer overflow | `INTEGER_OUT_OF_RANGE` |
| Numeric `-2 < 3` | True |
| Equal integers | True |
| String ordering | `INVALID_COMPARISON` |
| Mixed-type ordering | `INVALID_COMPARISON` |
| Unsafe head variable | `UNSAFE_VARIABLE` |
| Unsafe negation variable | `UNSAFE_VARIABLE` |
| Unsafe comparison variable | `UNSAFE_VARIABLE` |
| Safe rule | Validation succeeds |
| Atom arity mismatch | `ARITY_CONFLICT` |
| Arity plus safety error | Report arity first |
| Different insertion orders | Equal canonical output |
| Repeated lookup | Equal immutable results |
| Invalid JSON line | Protocol status `2` |
| Missing operation | Protocol status `2` |
| Unknown operation | Protocol status `2` |
| End of input | No extra response |

## Testing Requirements

Use Chicago-school tests. Test observable behavior on real domain objects. Inject external boundaries. Use in-memory relation stores and in-memory input and output channels. Do not use databases, files, network services, wall clocks, or background processes for unit and integration tests.

Write one black-box scenario for every probe operation. Assert domain payloads, exact error codes, stable JSON field order, output formatting, and exit statuses. Cover every row in the scenario matrix. Compare indexed lookup results with full scans. Verify failed operations preserve input values. Do not use tautological process tests. Do not use static sleep delays. If a future test uses a socket, poll readiness and enforce a maximum two-second timeout for every connection and read.

No feature in this story uses time, timers, dates, expiration, or schedules. Do not add a clock.

## Negative Constraints

Do not use mutable global state in core modules. Do not use hash-table iteration order for observable output. Do not use floating-point values for Datalog integers. Do not add evaluator or production CLI dependencies. Do not use placeholder returns, `pass`, ellipses, `NotImplementedError`, empty success branches, or suppressed shell failures. Do not use the legacy `docker-compose` command. This story does not require Docker Compose.

## Definition of Done (DoD)

- Create every required implementation and test file at the pinned paths.
- Keep modules single-purpose and imports acyclic.
- Implement immutable relations, tuples, and persistent indexes.
- Implement matching, substitutions, cycle detection, comparisons, and safety validation.
- Use signed `Int64.t` values and reject integer overflow.
- Implement all stable error identifiers and the `ERROR <CODE>:` renderer.
- Implement all five JSONL probe operations.
- Keep the executable wrapper below 15 lines when updated.
- Keep stdout free of progress and debug text.
- Keep stderr reserved for prefixed errors.
- Verify empty input produces no probe response.
- Verify every operation has a dedicated runnable black-box test.
- Verify every scenario and boundary case in the matrix.
- Run `dune build` and obtain status `0`.
- Run `dune runtest` and obtain status `0`.
- Run `dune exec test/test_us003_blackbox.exe < test/us003-cases.jsonl` and obtain status `0`.
- Achieve a 100 percent pass rate for unit, integration, and black-box tests.
- Record zero test failures and skip no required scenario.
- Treat lint output as advisory for this intermediate story.

```noctifab-contract
{
  "story_id": "US-003",
  "public_contracts": [
    {
      "id": "probe.jsonl",
      "interface": "dune exec test/test_us003_blackbox.exe",
      "applicable_path_prefixes": ["lib/", "test/", "bin/"],
      "allowed_executables": ["dune"],
      "exit_codes": [0, 1, 2, 3],
      "stdout_contains": ["\"ok\":true", "\"ok\":false"],
      "stderr_prefixes": ["ERROR "]
    },
    {
      "id": "build.test",
      "interface": "dune build && dune runtest",
      "applicable_path_prefixes": ["lib/", "test/"],
      "allowed_executables": ["dune"],
      "exit_codes": [0, 1],
      "stdout_contains": [],
      "stderr_prefixes": []
    }
  ]
}
```