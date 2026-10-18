# Task: Recursive descent parser for facts, rules, and queries

- **ID**: `task-621287f0`
- **Story ID**: `US-002`
- **Status**: `PENDING`
- **Change Type**: `FEATURE`
- **Depends On**: `AST contract, lexer, and parse error types`
- **Target Files**: `lib/parser.ml`, `test/test_parser.ml`, `test/test_parse_errors.ml`

## Description

Create lib/parser.ml implementing the grammar: program is statement* EOF; statement is fact, rule, or query; fact is atom then period; rule is atom then ':-' then literal list then period; query is '?-' then literal list then period; literal is optional 'not' atom or a comparison; atom requires parentheses and allows zero arguments; term is variable, constant, or wildcard. Expose 'val parse : string -> (Ast.program, Parse_error.t) result' as the public interface. Build the parser as deterministic immutable functions over the token stream from lib/lexer.mll; do not use mutable global parser state. Preserve source order in clause and literal lists and argument order in atoms. Reject a trailing comma in atom or literal argument lists with TRAILING_COMMA. Reject an empty rule body and empty query body with EMPTY_BODY. Reject a comparison missing an operator or with more than two terms with UNEXPECTED_TOKEN. Reject negated comparisons with UNEXPECTED_TOKEN. Require a final period for every clause and report MISSING_TERMINATOR when absent. Report UNEXPECTED_EOF when input ends mid-construct. Reject malformed trailing input after a valid final period. Report only the first invalid token found. Use direct imports of Ast, Lexer, and Parse_error modules; never import a package facade. Create test/test_parser.ml with fixed input strings covering scenarios P01 through P12 and P24 from the scenario matrix: zero-argument atoms, variables, strings, Int64 min and max, wildcards, negation, comparisons, comments ignored, and multi-statement source order. Create test/test_parse_errors.ml covering scenarios P13 through P22 and P25: integer overflow, missing terminator, trailing comma, empty bodies, unterminated string, unterminated comment, unexpected character, trailing input, and identical error values for repeated malformed input.
