# Task: AST contract, lexer, and parse error types

- **ID**: `task-9c79c272`
- **Story ID**: `US-002`
- **Status**: `PENDING`
- **Change Type**: `FEATURE`
- **Depends On**: `US-001-TASK-001`
- **Target Files**: `lib/ast.ml`, `lib/lexer.mll`, `lib/parse_error.ml`, `lib/dune`, `test/test_lexer.ml`

## Description

Update lib/ast.ml to keep Var, ConstString, ConstInt, ConstSymbol, Wildcard, PosAtom, NegAtom, Comparison, Fact, Rule, Query, symbol, term, atom, comp_op, literal, clause, program. Use a checked signed Int64 for ConstInt. Add a compatibility adapter function that converts legacy int to Int64 and rejects values that do not fit, raising a clear error instead of wrapping. Create lib/parse_error.ml with a public error kind variant covering UNEXPECTED_CHARACTER, UNEXPECTED_TOKEN, UNTERMINATED_STRING, UNTERMINATED_COMMENT, INVALID_INTEGER, INTEGER_OVERFLOW, MISSING_TERMINATOR, INVALID_IDENTIFIER, INVALID_PREDICATE, EMPTY_BODY, TRAILING_COMMA, UNEXPECTED_EOF. Store one-based line, one-based column, zero-based byte offset, and a message string in a record type t. Add a format function that renders 'error: parse: <KIND> at line <LINE>, column <COLUMN>: <MESSAGE>'. Create lib/lexer.mll (ocamllex) that tokenizes variables (uppercase or underscore start), symbols and predicates (lowercase start), digits and underscores after the first character, double-quoted strings with escaped quotes and backslashes, signed Int64 decimal literals, punctuation ':-', '?-', ',', '.', comparison operators '=', '!=', '<', '<=', '>', '>=', the 'not' keyword token, '%' line comments, '//' line comments, and '/* ... */' block comments. Track line, column, and byte offset for every token. Raise typed Parse_error.t values for unterminated strings, unterminated comments, invalid integers, integer overflow, and unexpected characters. Do not print anything from the lexer. Update lib/dune to compile the lexer module with a deterministic ocamllex rule. Create test/test_lexer.ml using Chicago-school tests with fixed input strings covering identifiers, strings with escapes, Int64 min and max values, Int64 overflow, all three comment forms, unterminated string, and unterminated comment. Use direct module imports; do not import a package facade.
