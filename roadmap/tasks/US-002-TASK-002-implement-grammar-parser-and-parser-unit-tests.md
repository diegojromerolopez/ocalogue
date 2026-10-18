# Task: Implement grammar parser and parser unit tests

- **ID**: `US-002-TASK-002`
- **Story ID**: `US-002`
- **Status**: `PENDING`
- **Change Type**: `FEATURE`
- **Depends On**: `US-002-TASK-001`
- **Target Files**: `lib/parser.ml`, `test/test_parser.ml`

## Description

Implement parser functions in lib/parser.ml. Parse facts, rules, and queries into the AST. Support terms, wildcards, negation, and comparisons. Validate grammar constraints and reject empty rule bodies or trailing commas. Return deterministic typed results with source locations. Add parser unit tests in test/test_parser.ml.
