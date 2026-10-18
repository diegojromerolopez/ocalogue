# Task: Implement parse CLI entrypoint and black-box tests

- **ID**: `US-002-TASK-003`
- **Story ID**: `US-002`
- **Status**: `PENDING`
- **Change Type**: `FEATURE`
- **Depends On**: `US-002-TASK-002`
- **Target Files**: `bin/main.ml`, `bin/dune`, `test/test_black_box_parse.ml`

## Description

Update bin/main.ml to add the parse command. Keep bin/main.ml below 15 lines. Print success summaries to stdout with exit code 0. Print error prefixes to stderr with exit code 1 or 2. Configure dune targets in bin/dune. Implement black-box execution tests in test/test_black_box_parse.ml.
