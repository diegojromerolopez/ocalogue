# Task: CLI Entry Point, Process Double, and Black-Box Tests

- **ID**: `task-1e17da9b`
- **Story ID**: `US-001`
- **Status**: `PENDING`
- **Change Type**: `FEATURE`
- **Depends On**: `US-001-TASK-001`, `US-001-TASK-002`
- **Target Files**: `bin/main.ml`, `test/support/in_memory_process.ml`, `test/test_ocalogue.ml`

## Description

Rewrite bin/main.ml as a thin wrapper under 15 lines. Delegate immediately to a callable function in Runner. Accept exactly one positional input path. Support `--help` and `-h`. Print help text starting with `Usage: ocalogue <input-file>`. Reject missing paths, extra arguments, and unknown options with exit status 2. Use exit status 0 for success and help. Use exit status 1 for runner errors. Print `OK <path>` to stdout on success. Print every error to stderr starting with `ocalogue: error: `. Print no diagnostic to stderr after success. Create test/support/in_memory_process.ml as an in-memory process double. Capture stdout, stderr, and exit status without a shell. Add CLI unit tests in test/test_ocalogue.ml using the process double for every argument and exit-status rule from scenarios S01 through S13. Add integration tests that run `dune build` and invoke `_build/default/bin/main.exe` as a real external process for black-box checks. Verify repeated runs produce byte-identical stdout and stderr. Give every test an explicit name. Make failure messages state the input, the expected result, and the observed result. Run `dune build` and `dune runtest` to confirm all tests pass.
