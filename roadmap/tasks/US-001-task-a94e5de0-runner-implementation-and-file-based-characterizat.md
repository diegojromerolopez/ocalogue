# Task: Runner Implementation and File-Based Characterization Tests

- **ID**: `task-a94e5de0`
- **Story ID**: `US-001`
- **Status**: `PENDING`
- **Change Type**: `FEATURE`
- **Depends On**: `US-001-TASK-001`
- **Target Files**: `lib/runner.ml`, `test/support/in_memory_filesystem.ml`, `test/fixtures/sample.dl`, `test/fixtures/empty.dl`, `test/fixtures/invalid_utf8.dl`, `test/test_ocalogue.ml`

## Description

Inspect existing lib/runner.ml behavior before changing code. Implement a callable runner function in lib/runner.ml. Accept one input path. Read the file without changing source bytes. Do not evaluate Datalog. Return a stable success result for a readable file. Raise a documented error with prefix `ocalogue: error: ` for missing, directory, or unreadable paths. Do not print diagnostics from this module. Do not use mutable state. Create test/support/in_memory_filesystem.ml as an in-memory file system double. Support readable, missing, empty, and invalid-UTF-8 input cases. Create test fixtures: test/fixtures/sample.dl, test/fixtures/empty.dl, test/fixtures/invalid_utf8.dl. Add characterization tests for the runner in test/test_ocalogue.ml. Cover success on a readable file, success on an empty file, failure on a missing file, failure on a directory path, and handling of invalid UTF-8 content. Give every test an explicit name. Make failure messages state the input, the expected result, and the observed result. Run `dune build` and `dune runtest` to confirm all runner tests pass.
