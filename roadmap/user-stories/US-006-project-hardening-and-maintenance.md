# US-006: Project Hardening, Maintenance Readiness & Code Quality

## Story

As a maintainer, I want repeatable quality, regression, packaging, and documentation checks, so I can release `ocalogue` with known behavior.

## Scope

Harden the complete repository after US-001 through US-005.

Run formatting, import, build, static analysis, unit, integration, black-box, packaging, documentation, and executable checks.

Record accepted static-analysis findings in a versioned tolerance document.

Keep all checks deterministic and suitable for local and continuous integration use.

## Dependencies

- Depends on: US-001, US-002, US-003, US-004, US-005
- Change type: new
- Complexity: 24 CU
- Domain capability: Quality, packaging, and maintenance

## Required Repository Paths

Create or update only these paths for this story, unless a test requires a co-located fixture:

- `dune-project`
- `dune-workspace`
- `Makefile`
- `Dockerfile`
- `README.md`
- `CONTRIBUTING.md`
- `QUALITY.md`
- `STATIC_ANALYSIS.md`
- `test_suite/01_transitive_closure.dl`
- `test_suite/02_same_generation.dl`
- `test_suite/03_stratified_negation.dl`
- `test_suite/04_mutual_recursion.dl`
- `test_suite/05_cyclic_termination.dl`
- `test_suite/06_unification_filters.dl`
- `test_suite/07_unstratified_negation_error.dl`
- `lib/dune`
- `lib/ast.ml`
- `lib/lexer.mll` or `lib/lexer.ml`
- `lib/parser.mly` or `lib/parser.ml`
- `lib/types.ml`
- `lib/relation.ml`
- `lib/unification.ml`
- `lib/stratify.ml`
- `lib/semi_naive.ml`
- `lib/engine.ml`
- `lib/runner.ml`
- `bin/dune`
- `bin/main.ml`
- `test/dune`
- `test/test_ocalogue.ml`
- `test/test_ast.ml`
- `test/test_unification.ml`
- `test/test_stratification.ml`
- `test/test_semi_naive.ml`
- `test/test_official_suite.ml`
- `test/test_black_box.ml`
- `test/test_quality.ml`
- `test/support/in_memory_process.ml`
- `test/support/mock_clock.ml`
- `test/support/fixture_loader.ml`
- `test/support/assertions.ml`

Keep internal modules independent from parent package facades or index modules.

## Observable Entry Points

Provide these repository commands:

- `dune build`
- `dune runtest`
- `dune build @check`
- `dune fmt --check`
- `make build`
- `make test`
- `make lint`
- `make format-check`
- `make package-check`
- `make docs-check`
- `make verify`
- `ocalogue run <file>`
- `ocalogue run <file> -q <query>`
- `ocalogue run <file> -q <query> --format=text`
- `ocalogue run <file> -q <query> --format=json`
- `ocalogue test <directory>`
- `ocalogue repl`

Use the executable at `_build/default/bin/main.exe` during repository checks.

Use the installed executable name `ocalogue` only after packaging installation.

Do not require a network service for this application.

Do not add HTTP, RESP, socket, or external service protocols.

## Command Contracts

### Successful commands

Return exit status `0`.

Write normal results to stdout.

Write no diagnostic text to stderr.

`make verify` must print these lines, in this order:

- `VERIFY: format PASS`
- `VERIFY: imports PASS`
- `VERIFY: static-analysis PASS`
- `VERIFY: build PASS`
- `VERIFY: unit PASS`
- `VERIFY: integration PASS`
- `VERIFY: black-box PASS`
- `VERIFY: package PASS`
- `VERIFY: documentation PASS`
- `VERIFY: executable PASS`
- `VERIFY: all checks passed`

### Failed commands

Return a non-zero exit status.

Write a stable diagnostic prefix to stderr.

Use these prefixes:

- `ERROR: format:`
- `ERROR: imports:`
- `ERROR: static-analysis:`
- `ERROR: build:`
- `ERROR: test:`
- `ERROR: black-box:`
- `ERROR: package:`
- `ERROR: documentation:`
- `ERROR: executable:`
- `ERROR: usage:`

Do not print success lines after a failed check.

Do not hide a command failure with `|| true`, `; true`, redirected status checks, or unconditional success commands.

### CLI sanity contract

For a valid source file, `ocalogue run <file>` returns `0`.

For a missing file, it returns non-zero and writes `ERROR: input: file not found` to stderr.

For malformed source, it returns non-zero and writes `ERROR: parse:` to stderr.

For an unsafe rule, it returns non-zero and writes `ERROR: safety:` to stderr.

For unstratified negation, it returns non-zero and writes `ERROR: NON_STRATIFIED_NEGATION` to stderr.

For an unknown command or option, it returns non-zero and writes `ERROR: usage:` to stderr.

Keep text result ordering deterministic by predicate, tuple, and binding value.

Encode JSON with valid UTF-8 and stable object-key order.

Represent all Datalog integers as signed 64-bit decimal values.

Reject values below `-9223372036854775808` or above `9223372036854775807`.

Do not round, truncate, or convert integer values to floating point.

## Static Analysis Policy

Run the repository formatter and import checks on every verification run.

Run `dune build @check` and the configured OCaml warning checks.

Run best-effort static analysis with the tools available in the project environment.

Document each unavailable tool and accepted finding in `STATIC_ANALYSIS.md`.

Set the tolerance budget to zero build errors, zero type errors, zero test failures, and zero unapproved warnings.

Allow only documented warning identifiers with an owner, reason, and removal condition.

Fail when a new warning exceeds the documented budget.

Never treat a missing analysis tool as a silent success.

## Formatting and Import Checks

Run `dune fmt --check` without changing files.

Check every OCaml source file under `lib/`, `bin/`, and `test/`.

Check module dependencies for forbidden imports from package facades.

Fail when a module imports an undeclared dependency or creates a dependency cycle.

Keep formatting changes separate from behavior changes.

## Regression and Black-Box Matrix

Execute all unit, integration, and black-box tests.

Run every official fixture through `ocalogue test test_suite/`.

Verify these fixture outcomes:

| Fixture | Required result |
|---|---|
| `01_transitive_closure.dl` | Derive `path(a, b)`, `path(a, c)`, `path(a, d)`, and `path(a, e)`. |
| `02_same_generation.dl` | Derive the three specified `same_generation` tuples. |
| `03_stratified_negation.dl` | Derive `unreachable(1, 4)`. |
| `04_mutual_recursion.dl` | Derive `even(0)`, `even(2)`, and `even(4)`. |
| `05_cyclic_termination.dl` | Terminate and derive the three specified `connected` tuples. |
| `06_unification_filters.dl` | Derive both specified `high_earner_dept` tuples. |
| `07_unstratified_negation_error.dl` | Reject the program with `NON_STRATIFIED_NEGATION` and a non-zero status. |

Run black-box tests through the executable boundary.

Do not call internal engine functions from black-box tests.

Use readiness polling for any process readiness check.

Do not use static sleep delays as readiness checks.

Use `test/support/in_memory_process.ml` for process and output doubles.

Use `test/support/fixture_loader.ml` for fixture loading.

Use `test/support/assertions.ml` for stable output assertions.

Use in-memory test doubles for domain and component tests.

Use `test/support/mock_clock.ml` for all time-dependent tests.

No feature in this story uses time, expiration, or TTL behavior.

## Scenario and Edge Case Matrix

Test the following cases:

1. Format all files with no diff.
2. Detect one changed-format file.
3. Build the complete project from a clean `_build` directory.
4. Run tests with all seven fixtures.
5. Run an empty fixture directory and return a clear non-zero usage or validation result.
6. Run a missing fixture directory and return `ERROR: input:`.
7. Run a missing source file and return the required error.
8. Run an empty source file and return a deterministic empty result.
9. Run a source file with comments and trailing whitespace.
10. Run a source file with signed 64-bit boundary values.
11. Reject both out-of-range integer boundaries.
12. Reject malformed JSON output requests only when the CLI option is invalid.
13. Verify text output contains no JSON syntax.
14. Verify JSON output contains the query, bindings, and count fields.
15. Verify declaration-order independence for official recursive fixtures.
16. Verify cyclic evaluation terminates without duplicate tuples.
17. Verify unsafe variables remain rejected.
18. Verify negative cycles remain rejected.
19. Verify an unknown CLI option returns a non-zero status.
20. Verify a missing CLI argument returns a non-zero status.
21. Verify package contents exclude `_build`, editor files, and temporary files.
22. Verify package contents include the executable, fixtures, documentation, and license metadata.
23. Verify a clean package installation can execute `ocalogue --help`.
24. Verify documentation commands match the implemented executable.
25. Verify documentation contains no placeholder, stub, or obsolete command.

## Packaging Checks

Build a release package from a clean workspace.

Include the Dune project, source modules, executable definition, tests, fixtures, README, contributing guide, quality policy, and static-analysis policy.

Exclude `_build/`, temporary files, editor backups, generated caches, and local logs.

Install the package into a temporary directory.

Run the installed executable with `--help`, one official fixture, and the unstratified fixture.

Remove the temporary installation after the check.

Fail if package creation or installation fails.

## Documentation Checks

Document build, test, lint, formatting, package, and verification commands in `README.md`.

Document contribution rules in `CONTRIBUTING.md`.

Document quality gates and required pass rates in `QUALITY.md`.

Document static-analysis tools, versions, findings, tolerance limits, and owners in `STATIC_ANALYSIS.md`.

Keep documentation examples executable and current.

Use short active sentences and standard technical terms.

## Anti-Stub and Anti-Gaming Rules

Implement every required check with real behavior.

Do not add `pass`, `...`, `NotImplementedError`, empty success handlers, fake reports, or hard-coded pass output.

Do not skip tests with annotations or filters.

Do not replace a failing check with a weaker check.

Do not mask shell errors with `|| true`, `; true`, or equivalent constructs.

Do not claim a static-analysis result when the tool did not run.

Do not weaken official fixture expectations.

## Acceptance Criteria

1. Run `make verify` from a clean checkout and obtain exit status `0`.
2. Confirm all ten required verification lines appear in the required order.
3. Confirm `dune build`, `dune runtest`, and `dune build @check` pass.
4. Confirm `dune fmt --check` passes without file changes.
5. Confirm import checks find no forbidden dependency.
6. Confirm the documented static-analysis tolerance budget is enforced.
7. Confirm all seven official fixtures pass at 100 percent.
8. Confirm every black-box scenario uses the executable boundary.
9. Confirm no black-box readiness test uses a static sleep delay.
10. Confirm all required error prefixes and exit statuses are stable.
11. Confirm signed 64-bit boundaries behave as specified.
12. Confirm packaging includes required files and excludes temporary files.
13. Confirm the installed package passes executable sanity checks.
14. Confirm documentation commands and output contracts match the implementation.
15. Confirm no forbidden stub or shell error masking exists.
16. Confirm unit, integration, and black-box suites have zero failures.

## Definition of Done

- Complete the required files and tests.
- Pass every acceptance criterion.
- Pass all unit, integration, and black-box tests.
- Pass the complete official fixture matrix.
- Record static-analysis results and approved findings.
- Verify the release package from a clean workspace.
- Review stdout, stderr, and exit status contracts.
- Review the change for deterministic behavior.
- Provide no known failing check.

## Machine-Readable Contract

```noctifab-contract
{
  "story_id": "US-006",
  "public_contracts": [
    {
      "id": "quality-verification-command",
      "interface": "make verify",
      "allowed_executables": ["make", "dune", "_build/default/bin/main.exe"],
      "exit_codes": {"success": 0, "failure": "non-zero"},
      "stdout_contains": [
        "VERIFY: format PASS",
        "VERIFY: imports PASS",
        "VERIFY: static-analysis PASS",
        "VERIFY: build PASS",
        "VERIFY: unit PASS",
        "VERIFY: integration PASS",
        "VERIFY: black-box PASS",
        "VERIFY: package PASS",
        "VERIFY: documentation PASS",
        "VERIFY: executable PASS",
        "VERIFY: all checks passed"
      ],
      "stderr_prefixes": [
        "ERROR: format:",
        "ERROR: imports:",
        "ERROR: static-analysis:",
        "ERROR: build:",
        "ERROR: test:",
        "ERROR: black-box:",
        "ERROR: package:",
        "ERROR: documentation:",
        "ERROR: executable:"
      ]
    },
    {
      "id": "datalog-executable",
      "interface": "ocalogue run <file> [-q <query>] [--format=text|json]",
      "allowed_executables": ["ocalogue", "_build/default/bin/main.exe"],
      "exit_codes": {"success": 0, "failure": "non-zero"},
      "stdout_contains": ["deterministic query results"],
      "stderr_prefixes": [
        "ERROR: input:",
        "ERROR: parse:",
        "ERROR: safety:",
        "ERROR: NON_STRATIFIED_NEGATION",
        "ERROR: usage:"
      ]
    }
  ]
}
```
