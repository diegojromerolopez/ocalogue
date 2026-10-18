# US-005: Batch CLI, JSON Results, REPL, and Official Suite

## User Story

As a Datalog user, run programs, inspect query results, use the REPL, and verify the official test suite.

## Scope

Implement the `run`, `test`, and `repl` commands. Support text output, JSON output, command-line queries, REPL loading, REPL assertions, help, and quit commands. Add all seven official fixtures and black-box validation.

Use the APIs from US-003 and US-004. Preserve declarative result semantics. Keep evaluation modules pure and immutable.

## Dependencies

depends_on: ["US-003", "US-004"]

change_type: "new"

## Requirements

1. Implement the executable at `_build/default/bin/main.exe` through Dune.
2. Accept `ocalogue run FILE` and evaluate queries in `FILE`.
3. Accept `ocalogue run FILE -q QUERY` and evaluate the ad-hoc query.
4. Accept `ocalogue run FILE -q QUERY --format=json`.
5. Accept `ocalogue test DIRECTORY` and run all seven official fixtures.
6. Accept `ocalogue repl` and show the prompt `ocalogue> `.
7. Support REPL commands `.help`, `.load FILE`, and `.quit`.
8. Accept facts and rules in the REPL and add them to the session program.
9. Print deterministic result order based on canonical term and tuple ordering.
10. Return `NON_STRATIFIED_NEGATION` for an unstratified program.
11. Keep `bin/main.ml` as a thin wrapper of fewer than 15 lines.
12. Delegate application work to testable functions in `lib/cli/app.ml`.
13. Use dependency injection for input, output, error output, and file access.
14. Use in-memory file doubles for unit and integration tests.
15. Ask whether a script can create or update structured JSON and fixture data more reliably than manual editing.
16. Do not add imperative state to AST, parsing, relation, unification, stratification, or evaluation modules.
17. Do not use live network services, external databases, background brokers, or container services for this story.

## Modular File Paths

Create or update only these responsibilities and paths:

### Implementation

- `bin/dune` — define the `ocalogue` executable.
- `bin/main.ml` — thin executable wrapper.
- `lib/cli/command.ml` — command and option data types.
- `lib/cli/run_command.ml` — batch `run` command orchestration.
- `lib/cli/test_command.ml` — official suite command orchestration.
- `lib/cli/repl_command.ml` — REPL loop and command dispatch.
- `lib/cli/input.ml` — injected input and file-reading boundary.
- `lib/cli/output.ml` — injected output boundary.
- `lib/cli/text_result.ml` — deterministic text result formatting.
- `lib/cli/json_result.ml` — JSON result formatting and escaping.
- `lib/cli/exit_status.ml` — process status values and error mapping.
- `lib/cli/app.ml` — testable application entry point `run : args:string list -> io:Io.t -> int`.
- `test_suite/01_transitive_closure.dl` — transitive closure fixture.
- `test_suite/02_same_generation.dl` — same-generation fixture.
- `test_suite/03_stratified_negation.dl` — stratified negation fixture.
- `test_suite/04_mutual_recursion.dl` — mutual recursion fixture.
- `test_suite/05_cyclic_termination.dl` — cyclic termination fixture.
- `test_suite/06_unification_filters.dl` — comparison and join fixture.
- `test_suite/07_unstratified_negation_error.dl` — rejection fixture.
- `Makefile` — `build`, `test`, and `e2e` recipes.

### Co-located Tests

- `test/test_cli_command.ml` — command parsing and validation.
- `test/test_run_command.ml` — batch execution behavior.
- `test/test_test_command.ml` — official suite behavior.
- `test/test_repl_command.ml` — REPL transitions and commands.
- `test/test_text_result.ml` — text formatting.
- `test/test_json_result.ml` — JSON formatting and escaping.
- `test/test_cli_errors.ml` — error messages and exit statuses.
- `test/test_official_suite.ml` — fixture expectations.
- `test/test_cli_e2e.ml` — physical black-box executable scenarios.

Keep internal module dependencies acyclic. Leaf modules must not import `Cli.App` or parent facade modules.

## Definition of Done (DoD)

### Public Interfaces and Entry Points

- Expose `Cli.App.run : args:string list -> io:Cli.Input.io -> int`.
- Expose `Cli.Text_result.render : query:string -> rows:Engine.binding list -> string`.
- Expose `Cli.Json_result.render : query:string -> rows:Engine.binding list -> string`.
- Build `_build/default/bin/main.exe` with Dune.
- Make `bin/main.ml` delegate immediately to `Cli.App.run`.
- Support `run`, `test`, and `repl` as the only top-level commands.

### Standard I/O and Output Contracts

- Print each text tuple on one line, such as `path(a, b)`.
- Print no result lines for an empty result set.
- Print JSON with fields `query`, `bindings`, and `count`.
- Print `count` as a non-negative decimal integer.
- Encode strings with valid JSON escaping.
- Print `ocalogue> ` before each REPL input line.
- Print `ocalogue Datalog REPL v1.0.0` when the REPL starts.
- Print `Fact asserted: FACT` after a valid REPL fact.
- Print `Loaded N facts, M rules.` after a valid `.load` command.
- Print help text when the user enters `.help`.
- Exit with status `0` after successful `run`, `test`, `repl`, `.quit`, and `.help` operations.
- Exit with status `1` for parse errors, evaluation errors, missing files, and `NON_STRATIFIED_NEGATION`.
- Exit with status `2` for invalid command-line options or missing required arguments.
- Print every error to stderr with prefix `Error: `.
- Print `Error: NON_STRATIFIED_NEGATION` for a negative dependency cycle.
- Do not print diagnostics to stdout.

### Data and Boundary Rules

- Preserve signed 64-bit integer values from `-9223372036854775808` through `9223372036854775807`.
- Preserve empty strings and escape quotes, backslashes, and control characters.
- Preserve wildcard and variable binding semantics from the engine.
- Return zero bindings and `count: 0` for a valid query with no matches.
- Reject an empty input file with status `0` and no result rows.
- Reject a missing input file with status `1` and an `Error: ` message.
- Reject an unknown command with status `2` and an `Error: ` message.
- Reject malformed JSON output requests with status `2`.
- Reject malformed Datalog with status `1`.
- Reject negative cycles before producing query results.
- Handle EOF in the REPL as `.quit`.
- Ignore supported comments and preserve quoted string values.

### Scenario and Edge-Case Matrix

| Scenario | Action | Expected result |
|---|---|---|
| Transitive closure | Run fixture 01 | Print four expected `path` tuples and exit `0` |
| Same generation | Run fixture 02 | Print three expected tuples and exit `0` |
| Stratified negation | Run fixture 03 | Print `unreachable(1, 4)` and exit `0` |
| Mutual recursion | Run fixture 04 | Print the three expected even tuples and exit `0` |
| Cyclic graph | Run fixture 05 | Terminate and print three expected tuples |
| Comparisons and joins | Run fixture 06 | Print both expected high-earner tuples |
| Negative cycle | Run fixture 07 | Print the required error and exit `1` |
| Ad-hoc query | Use `-q` | Evaluate only the supplied query |
| JSON query | Use `--format=json` | Produce valid JSON with exact count |
| Empty result | Query absent tuple | Produce no text rows or JSON bindings |
| Empty program | Run empty file | Exit `0` without result rows |
| Missing file | Use an absent path | Print `Error: ` and exit `1` |
| Bad option | Use an unknown flag | Print `Error: ` and exit `2` |
| REPL load | Enter `.load FILE` | Load facts and rules and print the count |
| REPL assertion | Enter a valid fact | Add the fact and confirm it |
| REPL help | Enter `.help` | Print command help |
| REPL quit | Enter `.quit` | Exit with status `0` |
| REPL EOF | Close input | Exit with status `0` |
| Large integer | Query signed 64-bit bounds | Preserve exact decimal values |
| Quoted value | Query escaped string data | Return valid escaped text and JSON |

### Testing and Verification

- Use Chicago-school tests with real AST, engine, formatter, and command objects.
- Inject `InMemoryInput`, `InMemoryOutput`, `InMemoryErrorOutput`, and `InMemoryFiles` in unit and integration tests.
- Do not use tautological tests, import-only tests, or connect-only tests.
- Run `dune runtest` and require 100% passing unit and integration tests.
- Run black-box tests against `_build/default/bin/main.exe`.
- Give every black-box process a maximum timeout of 2 seconds.
- Execute one black-box scenario for every command, flag, output format, REPL command, and official fixture.
- Assert real stdout, stderr, exit status, result payloads, and error payloads.
- Make black-box tests use process execution and realistic fixture files.
- Make `make test` fail with status `1` when zero tests run.
- Make `make build` compile the executable.
- Make `make e2e` execute all black-box scenarios and return status `0` only when all pass.
- Do not require zero lint errors for this feature story.

## Validation Criteria

1. Run `make build` and verify status `0`.
2. Run `make test` and verify every unit and integration test passes.
3. Run `make e2e` and verify every command and scenario passes.
4. Run all seven fixtures and compare exact expected results.
5. Verify deterministic text ordering and valid JSON parsing.
6. Verify all documented error prefixes and exit statuses.
7. Verify no implementation stub or placeholder remains.

```noctifab-contract
{
  "story_id": "US-005",
  "public_contracts": [
    {
      "id": "cli.batch-run",
      "interface": "CLI _build/default/bin/main.exe",
      "applicable_path_prefixes": ["bin/", "lib/cli/", "test_suite/"],
      "allowed_executables": ["_build/default/bin/main.exe"],
      "exit_codes": [0, 1, 2],
      "stdout_contains": ["path("],
      "stderr_prefixes": ["Error: "]
    },
    {
      "id": "cli.json-results",
      "interface": "CLI _build/default/bin/main.exe run --format=json",
      "applicable_path_prefixes": ["lib/cli/", "test/"],
      "allowed_executables": ["_build/default/bin/main.exe"],
      "exit_codes": [0, 1, 2],
      "stdout_contains": ["\"query\"", "\"bindings\"", "\"count\""],
      "stderr_prefixes": ["Error: "]
    },
    {
      "id": "cli.repl",
      "interface": "CLI _build/default/bin/main.exe repl",
      "applicable_path_prefixes": ["lib/cli/", "test/"],
      "allowed_executables": ["_build/default/bin/main.exe"],
      "exit_codes": [0, 1, 2],
      "stdout_contains": ["ocalogue> "],
      "stderr_prefixes": ["Error: "]
    },
    {
      "id": "cli.official-suite",
      "interface": "CLI _build/default/bin/main.exe test",
      "applicable_path_prefixes": ["lib/cli/", "test_suite/", "test/"],
      "allowed_executables": ["_build/default/bin/main.exe"],
      "exit_codes": [0, 1],
      "stdout_contains": ["PASS"],
      "stderr_prefixes": ["Error: "]
    }
  ]
}
```