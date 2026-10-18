# US-004: Stratified Semi-Naive Datalog Evaluation

## Story

As a Datalog user, I want safe stratified programs to reach a least fixed point, so recursive and negated rules return complete finite results.

## Scope

Implement dependency graphs, stratification, safety checks, and semi-naive evaluation.
Use immutable relations in every evaluation step.
Evaluate each stratum to completion before the next stratum.
Preserve the AST, relation, unification, and safety contracts from US-003.

Do not add batch commands, JSON output, or REPL commands.
US-005 owns those interfaces.

## Dependencies

- depends_on: [US-003]
- Use the public AST and relation interfaces from US-003.
- Do not change the grammar or AST without an approved dependency change.

## Required repository paths

Create or update only these paths:

- `lib/dependency_graph.ml`
- `lib/dependency_graph.mli`
- `lib/stratify.ml`
- `lib/stratify.mli`
- `lib/semi_naive.ml`
- `lib/semi_naive.mli`
- `lib/evaluator.ml`
- `lib/evaluator.mli`
- `lib/evaluation_error.ml`
- `lib/evaluation_error.mli`
- `lib/dune`
- `test/test_dependency_graph.ml`
- `test/test_stratify.ml`
- `test/test_semi_naive.ml`
- `test/test_evaluator.ml`
- `test/test_evaluation_blackbox.ml`
- `test/dune`

Keep each implementation file focused on one responsibility.
Keep each test file focused on its matching module or contract.
Do not import a parent facade from an internal module.
Keep internal module dependencies acyclic.

## Public interfaces

Expose these interfaces:

- `Evaluator.evaluate : Ast.program -> (Evaluator.result, Evaluation_error.t) result`
- `Dependency_graph.of_program : Ast.program -> Dependency_graph.t`
- `Stratify.compute : Dependency_graph.t -> (Stratify.plan, Evaluation_error.t) result`
- `Semi_naive.evaluate : Stratify.plan -> Ast.program -> (Evaluator.result, Evaluation_error.t) result`
- `Evaluation_error.code : Evaluation_error.t -> string`
- `Evaluation_error.detail : Evaluation_error.t -> string`

Use the exact public types from US-003 where they already exist.
Return immutable relations and immutable query bindings.

## Black-box protocol

Build `test/evaluation_blackbox.exe` through Dune.

Run:

`dune exec test/evaluation_blackbox.exe -- <program-file>`

Read one UTF-8 file path from `argv[1]`.
Read no program data from standard input.
Write result lines to standard output.
Write diagnostics to standard error.

For success, print one sorted line for each query result:

`RESULT <predicate>(<term>,...)`

Print `RESULT EMPTY` for a valid query without results.
Print `EVALUATION_OK` after all query results.
Exit with status `0`.

For an evaluation error, print no result lines.
Write this exact prefix to standard error:

`ocalogue: error: `

Write one stable error code and one short detail after the prefix.
Exit with status `1`.

For invalid arguments or an unreadable file, write:

`ocalogue: error: INVALID_INPUT <detail>`

Exit with status `2`.

Sort predicates, tuples, and bindings by canonical UTF-8 text.
Do not expose hash iteration order.

## Functional requirements

### Dependency graph

1. Add one node for every predicate in facts, heads, and body atoms.
2. Add one edge from each rule head to each body predicate.
3. Mark negated body edges as negative.
4. Preserve positive and negative parallel edges.
5. Use immutable maps, sets, and records.
6. Return deterministic node and edge order.

### Stratification

1. Reject every directed cycle that contains a negative edge.
2. Return `NON_STRATIFIED_NEGATION` for each rejected program.
3. Include ordered cycle predicates in the error detail.
4. Accept positive recursion and mutual positive recursion.
5. Assign each predicate a non-negative stratum.
6. Keep positive dependencies in the same or an earlier stratum.
7. Place negative dependencies in an earlier stratum.
8. Evaluate strata in ascending order.
9. Finish one stratum before starting the next.
10. Keep extensional facts available to later strata.

### Safety and validation

1. Reject an unsafe rule with `UNSAFE_RULE`.
2. Require head variables to occur in positive atoms.
3. Require negated-atom variables to occur in positive atoms.
4. Require comparison variables to occur in positive atoms.
5. Reject inconsistent predicate arity with `ARITY_CONFLICT`.
6. Reject incompatible comparison terms with `INVALID_COMPARISON`.
7. Preserve zero-arity predicate semantics when the AST supports them.

### Semi-naive evaluation

1. Store every relation as an immutable persistent set.
2. Maintain `full`, `delta`, and `next_delta` for current-stratum predicates.
3. Seed `full` and `delta` with known facts.
4. Evaluate every eligible positive body position with `delta` once per iteration.
5. Use `full` for other positive body positions.
6. Use completed lower-stratum relations for negated atoms.
7. Apply comparisons after required bindings exist.
8. Add only tuples absent from `full` and `next_delta`.
9. Replace `delta` with `next_delta` after each iteration.
10. Stop when every delta relation is empty.
11. Return the complete least fixed point.
12. Terminate on finite self cycles, mutual cycles, and graph cycles.
13. Avoid a full recursive join when a differential join applies.
14. Evaluate rules without positive recursive atoms during initial or non-recursive evaluation.

### Term representation

1. Use `Int64.t` for integer terms and comparisons.
2. Accept values from `-9223372036854775808` through `9223372036854775807`.
3. Reject overflow without wraparound.
4. Preserve strings after parsing and unescaping.
5. Sort integers in base ten without a leading plus sign.
6. Sort symbols by source spelling.
7. Sort strings in escaped double-quoted form.
8. Do not emit variables in ground result tuples.

## Scenario matrix

| Case | Required result |
|---|---|
| Empty program | Print `EVALUATION_OK` and no result tuple. |
| Single fact | Return the fact once. |
| Positive recursion | Return every transitive-closure tuple. |
| Mutual recursion | Return the finite even and odd fixed point. |
| Positive self cycle | Terminate and retain the seed tuple. |
| Cyclic graph | Return each reachable tuple once. |
| Lower-stratum negation | Evaluate the lower stratum first. |
| Negative cycle | Return `NON_STRATIFIED_NEGATION` with status `1`. |
| Unsafe negation | Return `UNSAFE_RULE` with status `1`. |
| Arity mismatch | Return `ARITY_CONFLICT` with status `1`. |
| Invalid comparison | Return `INVALID_COMPARISON` with status `1`. |
| Duplicate derivation | Emit one tuple. |
| Empty differential | Stop without another recursive join. |
| Zero-arity predicate | Preserve zero-arity results. |
| Maximum Int64 | Accept and preserve the value. |
| Minimum Int64 | Accept and preserve the value. |
| Integer overflow | Return `INVALID_INPUT` with status `2`. |
| Reordered facts | Produce byte-identical output. |
| Reordered rules | Produce byte-identical output. |
| Missing file | Return `INVALID_INPUT` with status `2`. |
| Extra argument | Return `INVALID_INPUT` with status `2`. |
| Empty query result | Print `RESULT EMPTY` and succeed. |

## Testing requirements

Use Chicago-school tests on real domain objects.
Use in-memory relation stores and dependency graph inputs as test doubles.
Do not use a database, network service, external process, or wall clock in unit tests.
Use deterministic mock clocks if future time behavior appears.
This story has no time behavior.

Add unit tests for graph construction, negative cycles, strata, safety, arity, comparisons, Int64 limits, and immutable updates.
Add integration tests for recursive joins, multiple strata, negation, comparisons, duplicate derivations, and declaration-order independence.
Add black-box tests for every scenario in the matrix.
Run each black-box feature through the executable.
Assert stdout, stderr, exit status, and canonical ordering.
Use readiness polling instead of static sleep delays if a process wrapper is used.
Set a maximum two-second timeout for every process or socket operation.
Do not write tautological tests.

Test each public capability with a dedicated black-box scenario:

- Evaluate an empty program.
- Evaluate a fact.
- Evaluate positive recursion.
- Evaluate mutual recursion.
- Evaluate self and graph cycles.
- Evaluate lower-stratum negation.
- Reject a negative cycle.
- Reject an unsafe rule.
- Reject an arity conflict.
- Reject an invalid comparison.
- Verify Int64 boundaries and overflow.
- Verify invalid paths and arguments.
- Verify empty query output.
- Verify deterministic output after fact and rule reordering.

## Implementation constraints

Use immutable `Set`, `Map`, records, and algebraic data types.
Use tail-recursive folds where suitable.
Do not use mutable references, arrays, hash tables, global state, or side effects in core evaluation.
Do not use floating-point values for Datalog integers.
Do not use `pass`, `...`, `NotImplementedError`, placeholder results, or unconditional success.
Do not mask command failures with `|| true`.
Do not add forbidden tools or frameworks.
Ask whether an automated script can create structured fixtures more reliably than manual editing.

Keep `test/evaluation_blackbox.exe` as a thin wrapper.
Delegate evaluation to `Evaluator.evaluate`.
Keep the wrapper below fifteen lines where practical.

## Definition of Done (DoD)

### Required implementation and test files

Create and complete every path listed in this section:

- `lib/dependency_graph.ml`
- `lib/dependency_graph.mli`
- `lib/stratify.ml`
- `lib/stratify.mli`
- `lib/semi_naive.ml`
- `lib/semi_naive.mli`
- `lib/evaluator.ml`
- `lib/evaluator.mli`
- `lib/evaluation_error.ml`
- `lib/evaluation_error.mli`
- `lib/dune`
- `test/test_dependency_graph.ml`
- `test/test_stratify.ml`
- `test/test_semi_naive.ml`
- `test/test_evaluator.ml`
- `test/test_evaluation_blackbox.ml`
- `test/dune`

### Completion checks

- Build `test/evaluation_blackbox.exe` through Dune.
- Pass all unit tests with zero failures.
- Pass all integration tests with zero failures.
- Pass every black-box scenario with a 100 percent pass rate.
- Verify declaration-order independence.
- Verify finite termination for all positive cycle cases.
- Verify exact negative-cycle errors.
- Verify Int64 limits without overflow or wraparound.
- Verify deterministic stdout, stderr, ordering, and exit statuses.
- Run `dune build` successfully.
- Run `dune runtest` successfully.
- Confirm that no required implementation contains a stub.
- Confirm that no command masks a failure.
- Confirm that internal imports form a directed acyclic graph.
- Confirm that tests use in-memory doubles and real domain objects.
- Confirm that each feature has a dedicated black-box scenario.

### Validation commands

Run these commands:

- `dune build`
- `dune runtest`
- `dune exec test/evaluation_blackbox.exe -- test_suite/01_transitive_closure.dl`
- `dune exec test/evaluation_blackbox.exe -- test_suite/04_mutual_recursion.dl`
- `dune exec test/evaluation_blackbox.exe -- test_suite/05_cyclic_termination.dl`
- `dune exec test/evaluation_blackbox.exe -- test_suite/07_unstratified_negation_error.dl`

Confirm each command returns its specified status.

### Makefile policy

This story does not add a Makefile.
If a Makefile exists, keep these recipes correct:

- `build`: compile the project.
- `test`: compile and run tests, and fail when zero tests run.
- `e2e`: execute real black-box scenarios for every feature in this story.

Use `docker compose -f docker-compose.e2e.yml up --build --exit-code-from <service>` for containerized end-to-end validation.
Do not use the hyphenated `docker-compose` command.

## Error contract

Use these stable codes:

- `NON_STRATIFIED_NEGATION`
- `UNSAFE_RULE`
- `ARITY_CONFLICT`
- `INVALID_COMPARISON`
- `INVALID_INPUT`

Use `ocalogue: error: <CODE> <detail>`.
Do not expose exception names, stack traces, addresses, or nondeterministic text.

## Change metadata

- `change_type: new`
- `complexity: 35 CU`

```noctifab-contract
{
  "story_id": "US-004",
  "public_contracts": [
    {
      "id": "stratified-evaluation-blackbox",
      "interface": "dune exec test/evaluation_blackbox.exe -- <program-file>",
      "applicable_path_prefixes": ["lib/", "test/"],
      "allowed_executables": ["dune", "test/evaluation_blackbox.exe"],
      "exit_codes": [0, 1, 2],
      "stdout_contains": ["EVALUATION_OK", "RESULT EMPTY"],
      "stderr_prefixes": ["ocalogue: error: "]
    }
  ]
}
```