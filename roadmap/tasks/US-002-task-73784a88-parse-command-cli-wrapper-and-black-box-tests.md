# Task: Parse command CLI wrapper and black-box tests

- **ID**: `task-73784a88`
- **Story ID**: `US-002`
- **Status**: `PENDING`
- **Change Type**: `FEATURE`
- **Depends On**: `Recursive descent parser for facts, rules, and queries`
- **Target Files**: `bin/main.ml`, `bin/dune`, `test/test_black_box_parse.ml`

## Description

Create a core callable function in lib that reads a file path, calls Parser.parse, and returns a structured result with clause count or a Parse_error.t. Update bin/main.ml as a thin wrapper under 15 lines that parses argv for the 'parse <FILE>' subcommand and delegates immediately to the core function. On success print 'Parsed <N> clauses.' to stdout with one trailing newline and exit 0. On a missing file or any lexical or syntax error print 'error: parse: <KIND> at line <LINE>, column <COLUMN>: <MESSAGE>' to stderr and exit 1. On a missing subcommand, unknown subcommand, or extra positional argument print 'error: usage: <MESSAGE>' to stderr and exit 2. Never write logs, warnings, or debug text to stdout. Update bin/dune to link the lib library. Create test/test_black_box_parse.ml that spawns 'dune exec bin/main.exe -- parse <FILE>' as a child process, waits for completion, and checks stdout, stderr, and exit code separately for scenarios P01, P15 through P23, P26, and P27 from the scenario matrix. Use in-memory fixture files written to a temporary test directory, not network services or wall-clock timing. Use an in-memory test double for file input and command output in a component-level test that calls the core function directly without spawning a process.
