# Task: Implement AST updates, error types, and lexical analyzer

- **ID**: `US-002-TASK-001`
- **Story ID**: `US-002`
- **Status**: `PENDING`
- **Change Type**: `FEATURE`
- **Depends On**: `US-001-TASK-001`
- **Target Files**: `lib/ast.ml`, `lib/parse_error.ml`, `lib/lexer.ml`, `lib/dune`, `test/test_lexer.ml`, `test/test_parse_errors.ml`

## Description

Update AST types in lib/ast.ml for signed Int64 support. Implement error types and locations in lib/parse_error.ml. Implement the lexer in lib/lexer.ml. Tokenize variables, symbols, strings with escapes, Int64 integers, operators, and comments. Report exact line, column, and byte offsets for lexical errors. Add unit tests in test/test_lexer.ml and test/test_parse_errors.ml.
