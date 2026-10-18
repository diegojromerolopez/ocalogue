# US-001: Legacy Codebase Characterization and Stabilization

## User Story

As a maintainer, I want tested legacy behavior and a working Dune skeleton, so later refactoring has regression protection.

## Scope

Inspect the existing AST, runner, and test behavior before changing code.

Create the smallest runnable OCaml project around the legacy modules.

Keep the CLI thin and callable from tests.

Do not implement parsing, evaluation, stratification, JSON output, or the REPL.

Do not claim signed 64-bit integer support in this story.

## Dependencies

- `depends_on: []`
- `change_type: new`
- Complexity: 24 CU

## Public Interfaces

Implement `Runner.run : string -> (string, string) result`.

Return the unchanged readable input path on success.

Return an error string with prefix `ocalogue: error: ` on runner failure.

Implement `Runner.run_argv : string array -> int` for CLI execution.

Accept one input path, `--help`, or `-h`.

Return status `0` for success and help.

Return status `1` for readable-file or runner errors.

Return status `2` for usage errors.

Build the executable at `_build/default/bin/main.exe`.

Install the executable as `ocalogue` when Dune installation is available.

## Modular Repository Paths

Create or update these paths:

- `dune-project`
- `Makefile`
- `lib/dune`
- `lib/ast.ml`
- `lib/runner.ml`
- `bin/dune`
- `bin/main.ml`
- `test/dune`
- `test/test_ast.ml`
- `test/test_runner.ml`
- `test/test_cli.ml`
- `test/test_integration.ml`
- `test/test_black_box.ml`
- `test/support/in_memory_process.ml`
- `test/support/in_memory_filesystem.ml`
- `test/fixtures/empty.dl`
- `test/fixtures/invalid_utf8.dl`
- `test/fixtures/sample.dl`

Keep `test/test_ocalogue.ml` only as a compatibility coordinator if the existing build requires it.

Keep each test file focused on one responsibility.

Keep each module independent from parent package facades and index modules.

Use direct module imports only.

Keep internal imports acyclic.

## AST Contract

Define these immutable types in `lib/ast.ml`:

```ocaml
type symbol = string

type term =
  | Var of string
  | ConstString of string
  | ConstInt of int
  | ConstSymbol of symbol
  | Wildcard

type atom = { predicate: symbol; args: term list }

type comp_op = Eq | Neq | Lt | Le | Gt | Ge

type literal =
  | PosAtom of atom
  | NegAtom of atom
  | Comparison of term * comp_op * term

type clause =
  | Fact of atom
  | Rule of atom * literal list
  | Query of literal list

type program = clause list
```

Use immutable values in the AST.

Preserve empty lists, empty strings, nested values, and host OCaml `int` values.

Do not add parser or evaluator behavior.

## Runner Contract

Read the input file without changing its source bytes.

Validate that the path identifies a readable regular file.

Return a stable success result for empty and non-empty readable files.

Return a deterministic error for a missing path, directory path, or unreadable path.

Handle invalid UTF-8 without an uncaught exception.

Do not evaluate Datalog.

Do not print from library modules.

Write diagnostics only through the CLI layer.

Use the error prefix `ocalogue: error: ` for every error line.

## CLI Contract

Keep `bin/main.ml` under 15 lines.

Delegate immediately to `Runner.run_argv`.

Accept exactly one positional input path.

Support `--help` and `-h`.

Reject missing paths, extra arguments, and unknown options.

Print success to stdout as exactly `OK <path>`.

Print help to stdout with the first line `Usage: ocalogue <input-file>`.

Print errors to stderr.

Start every error line with `ocalogue: error: `.

Print no stderr diagnostic after success or help.

Use no timestamps, colors, memory addresses, or other nondeterministic text.

Treat a path containing spaces as one argument.

## Makefile Contract

Provide `build`, `test`, `e2e`, `clean`, `lint`, and `format` targets.

Make `build` run `dune build`.

Make `test` run `dune runtest` and fail when no tests run.

Make `e2e` run all black-box CLI scenarios against the built executable.

Make `clean` run `dune clean`.

Make `lint` run a real check and return its failure status.

Make `format` run the configured formatter and return its failure status.

Do not use `|| true`, redirected failure suppression, ignored statuses, or shell error masking.

Do not place implementation logic in Makefile recipes.

Do not use `docker-compose`; this story needs no container service.

## Test Requirements

Use Chicago-school tests with real module calls and observable results.

Use dependency injection for filesystem and process boundaries.

Create and use `In_memory_filesystem` for readable, missing, empty, directory, and invalid input paths.

Create and use `In_memory_process` for stdout, stderr, and exit status assertions.

Use real domain objects in unit tests.

Use no network sockets because this story defines no network protocol.

Use no static sleep or readiness polling because no server starts.

Use no real clock because this story has no time behavior.

Ask whether an automated script can create or validate structured fixtures more reliably than manual editing.

## Scenario Matrix

| ID | Input | Expected result |
|---|---|---|
| S01 | Existing readable sample file | Exit `0`; stdout is `OK <path>`; stderr is empty |
| S02 | Empty readable file | Exit `0`; stdout is `OK <path>`; stderr is empty |
| S03 | Missing file | Exit `1`; stderr starts with `ocalogue: error: ` |
| S04 | Directory path | Exit `1`; stderr starts with `ocalogue: error: ` |
| S05 | `--help` | Exit `0`; stdout starts with the required usage line |
| S06 | `-h` | Exit `0`; stdout starts with the required usage line |
| S07 | No arguments | Exit `2`; stderr starts with `ocalogue: error: ` |
| S08 | Two input paths | Exit `2`; stderr starts with `ocalogue: error: ` |
| S09 | Unknown option | Exit `2`; stderr starts with `ocalogue: error: ` |
| S10 | Path containing spaces | Treat the path as one argument and apply the file contract |
| S11 | Very long valid path | Return deterministic success or error without truncation |
| S12 | Invalid UTF-8 fixture | Do not crash; return the documented runner result or error |
| S13 | Repeated execution | Produce byte-identical stdout and stderr |
| S14 | Empty AST lists and strings | Preserve values without omission or mutation |
| S15 | Host `int` boundary values | Preserve values supported by the host representation |

## Negative Constraints

Do not add parser, lexer, evaluator, stratification, JSON, REPL, or official-suite behavior.

Do not use mutable state in AST or runner logic.

Do not use network services, external databases, generated code, or imperative evaluation algorithms.

Do not use placeholder branches, unconditional success, or broad exception-to-success conversion.

Do not add unsupported signed 64-bit behavior.

## Definition of Done (DoD)

- Create every listed repository path.
- Compile `lib/ast.ml` and `lib/runner.ml` with Dune.
- Build `_build/default/bin/main.exe` successfully.
- Build the test executable successfully.
- Expose the exact `Runner.run` and `Runner.run_argv` contracts.
- Keep `bin/main.ml` under 15 lines.
- Characterize constructors, printers, equality behavior, runner behavior, and failures.
- Add separate AST, runner, CLI, integration, and black-box test modules.
- Add and use both in-memory test doubles.
- Test every scenario in the matrix.
- Execute each CLI flag and argument rule through a dedicated black-box scenario.
- Verify stdout, stderr, and exit status exactly.
- Verify repeated execution produces identical output.
- Run `dune build` with exit status `0`.
- Run `dune runtest` with exit status `0` and at least one test.
- Run `make e2e` with exit status `0`.
- Require a 100 percent pass rate for unit, integration, and black-box tests.
- Require zero test failures and zero unexpected output lines.
- Verify no forbidden placeholder or error-masking pattern exists.
- Keep internal module imports acyclic.
- Do not require zero lint errors for this intermediate story.
- Confirm later stories can extend the AST without changing this CLI contract.

```noctifab-contract
{
  "story_id": "US-001",
  "public_contracts": [
    {
      "id": "cli-file-check",
      "interface": "_build/default/bin/main.exe <input-file>",
      "applicable_path_prefixes": ["bin/", "lib/", "test/"],
      "allowed_executables": ["dune", "_build/default/bin/main.exe", "ocalogue"],
      "exit_codes": [0, 1, 2],
      "stdout_contains": ["OK <path>", "Usage: ocalogue <input-file>"],
      "stderr_prefixes": ["ocalogue: error: "]
    },
    {
      "id": "build-and-test",
      "interface": "dune build && dune runtest",
      "applicable_path_prefixes": ["dune-project", "lib/", "bin/", "test/"],
      "allowed_executables": ["dune"],
      "exit_codes": [0],
      "stdout_contains": [],
      "stderr_prefixes": []
    }
  ]
}
```