# US-002: Datalog Lexing and Parsing

## Story

As a Datalog user, parse source text into the shared AST. Reject invalid source with deterministic errors.

## Metadata

- Story ID: US-002
- Slug: US-002-datalog-lexing-and-parsing
- Domain: Source language front end
- Depends on: US-001
- Complexity: 27 CU
- Change type: new

## Scope

Implement a deterministic lexer and parser for the Datalog language.

Preserve the public AST contract in `lib/ast.ml`.

Parse facts, rules, queries, terms, comparisons, negation, comments, strings, signed 64-bit integers, and wildcards.

Return stable source locations for invalid input.

Do not implement evaluation, unification, stratification, or result formatting.

## Required implementation paths

Create or update only these paths:

- `lib/ast.ml`
- `lib/lexer.ml` or `lib/lexer.mll`
- `lib/parser.ml` or `lib/parser.mly`
- `lib/parse_error.ml`
- `lib/dune`
- `bin/main.ml`
- `bin/dune`

Keep lexer and parser modules separate.

Keep parse errors in `lib/parse_error.ml`.

Use direct module imports. Do not import a package facade or index module from internal modules.

Keep the executable wrapper below 15 lines. Delegate immediately to a testable command function.

## Required test paths

Create these separate test files:

- `test/test_lexer.ml`
- `test/test_parser.ml`
- `test/test_parse_errors.ml`
- `test/test_black_box_parse.ml`
- `test/dune`

Keep lexical tests, parser tests, error tests, and command tests separate.

Use Chicago-school tests with real module collaborators.

Use in-memory input and output doubles for component tests.

Use a controlled child-process fixture for black-box command tests.

## Public AST contract

Retain these constructors and fields:

- `Var of string`
- `ConstString of string`
- `ConstInt`
- `ConstSymbol of string`
- `Wildcard`
- `PosAtom of atom`
- `NegAtom of atom`
- `Comparison of term * comp_op * term`
- `Fact of atom`
- `Rule of atom * literal list`
- `Query of literal list`

Retain `symbol`, `term`, `atom`, `comp_op`, `literal`, `clause`, and `program` as public concepts.

Represent integer values without truncation on supported OCaml 5.x platforms.

If the existing AST uses `int`, add a checked compatibility adapter. Reject values outside its supported range.

Do not wrap, round, clamp, or silently change integer values.

Preserve clause, literal, and atom argument order.

Represent `_` as `Wildcard` in every occurrence.

Treat each named variable as a variable with exact spelling.

## Lexical contract

Accept variables that start with an uppercase letter or underscore.

Accept symbols and predicate names that start with a lowercase letter.

Allow letters, digits, and underscores after the first identifier character.

Treat lowercase `not` as a keyword, not as a symbol.

Accept double-quoted strings.

Decode escaped double quotes and escaped backslashes.

Reject unterminated strings.

Accept signed decimal integers from `-9223372036854775808` through `9223372036854775807`.

Accept `:-`, `?-`, `,`, `.`, `=`, `!=`, `<`, `<=`, `>`, and `>=`.

Support `%` and `//` comments through the next line ending.

Support `/* ... */` comments across lines.

Reject unterminated block comments.

Allow horizontal and vertical whitespace.

Reject unexpected bytes.

Track a zero-based byte offset, one-based line, and one-based column.

## Grammar contract

Implement this grammar:

- `program ::= statement* EOF`
- `statement ::= fact | rule | query`
- `fact ::= atom "."`
- `rule ::= atom ":-" literal ("," literal)* "."`
- `query ::= "?-" literal ("," literal)* "."`
- `literal ::= ["not"] atom | comparison`
- `comparison ::= term comp_op term`
- `atom ::= predicate "(" [term ("," term)*] ")"`
- `term ::= variable | constant | wildcard`
- `constant ::= symbol | string | integer`

Require parentheses for every predicate argument list.

Allow zero arguments in an atom.

Reject trailing commas.

Reject empty rule and query bodies.

Reject comparisons without an operator.

Reject comparisons with more than two terms.

Allow comparisons and negated atoms in rule and query bodies.

Reject negated comparisons.

Require a final period for every fact, rule, and query.

Allow an empty program.

## Error contract

Expose a typed result or a documented exception through the parser interface.

Do not print errors from lexer or parser library functions.

Use these error kinds:

- `UNEXPECTED_CHARACTER`
- `UNEXPECTED_TOKEN`
- `UNTERMINATED_STRING`
- `UNTERMINATED_COMMENT`
- `INVALID_INTEGER`
- `INTEGER_OVERFLOW`
- `MISSING_TERMINATOR`
- `INVALID_IDENTIFIER`
- `INVALID_PREDICATE`
- `EMPTY_BODY`
- `TRAILING_COMMA`
- `UNEXPECTED_EOF`

Use this command error format:

`error: parse: <KIND> at line <LINE>, column <COLUMN>: <MESSAGE>`

Report the first invalid token only.

Return the same error kind, location, and message for repeated identical input.

Write successful summaries to stdout only.

Write errors to stderr only.

Exit with status 0 after success.

Exit with status 1 for file, lexical, syntax, or input errors.

Exit with status 2 for command usage errors.

## Command contract

Expose:

`dune exec bin/main.exe -- parse <FILE>`

Also support:

`ocalogue parse <FILE>`

Read the complete UTF-8 file.

Print exactly one success line:

`Parsed <N> clauses.`

Terminate the line with one newline.

Use decimal digits for `<N>`.

Report a missing file with status 1 and prefix `error: parse:`.

Report an extra positional argument with status 2 and prefix `error: usage:`.

Do not add a network protocol, socket listener, or REPL in this story.

## Scenario matrix

| ID | Input or condition | Expected result |
|---|---|---|
| P01 | `parent(alice, bob).` | One `Fact` clause |
| P02 | `path(X, Y) :- edge(X, Y).` | One `Rule` clause |
| P03 | `?- path(alice, X).` | One `Query` clause |
| P04 | `p().` | Zero-argument atom |
| P05 | `p(X, "A", -10, _).` | Variable, string, signed integer, and wildcard |
| P06 | `p(X) :- q(X), not r(X), X >= 10.` | Positive atom, negation, and comparison |
| P07 | `% note\np(a).` | Line comment ignored |
| P08 | `// note\np(a).` | Line comment ignored |
| P09 | `/* note */ p(a).` | Block comment ignored |
| P10 | `p("a\\\"b").` | Escaped string decoded |
| P11 | `p(9223372036854775807).` | Maximum signed 64-bit integer accepted |
| P12 | `p(-9223372036854775808).` | Minimum signed 64-bit integer accepted |
| P13 | `p(9223372036854775808).` | `INTEGER_OVERFLOW`, status 1 |
| P14 | `p(-9223372036854775809).` | `INTEGER_OVERFLOW`, status 1 |
| P15 | `p(a)` | `MISSING_TERMINATOR`, status 1 |
| P16 | `p(a,).` | `TRAILING_COMMA`, status 1 |
| P17 | `p(a) :- .` | `EMPTY_BODY`, status 1 |
| P18 | `?- .` | `EMPTY_BODY`, status 1 |
| P19 | `p("unterminated).` | `UNTERMINATED_STRING`, status 1 |
| P20 | `/* unterminated` | `UNTERMINATED_COMMENT`, status 1 |
| P21 | `p(a) @.` | `UNEXPECTED_CHARACTER`, status 1 |
| P22 | `p(a) . trailing` | Invalid trailing input, status 1 |
| P23 | Empty input | Zero clauses, status 0 |
| P24 | Multiple statements | Source order preserved |
| P25 | Same malformed input twice | Identical structured and text errors |
| P26 | Missing file | Parse error prefix, status 1 |
| P27 | Extra command argument | Usage error prefix, status 2 |

## Definition of Done (DoD)

### Public interfaces and entry points

- Implement `Parser.parse : string -> (Ast.program, Parse_error.t) result`, or document the equivalent typed public interface.
- Implement a callable command function for `parse` that accepts injected input and output boundaries.
- Expose `dune exec bin/main.exe -- parse <FILE>`.
- Support `ocalogue parse <FILE>`.
- Keep `bin/main.ml` below 15 lines and delegate immediately.

### Data and output invariants

- Preserve AST constructors, fields, clause order, literal order, and argument order.
- Preserve exact variable spelling.
- Represent `_` as `Wildcard`.
- Parse the complete signed 64-bit range without truncation.
- Reject overflow and invalid integer text.
- Return an empty program for empty input.
- Print `Parsed <N> clauses.` and one newline on success.
- Write no success text to stderr.
- Write parse errors only to stderr.
- Use status 0 for success, status 1 for input and parse errors, and status 2 for usage errors.
- Use the exact `error: parse:` and `error: usage:` prefixes.

### Required implementation and test files

- Implement `lib/ast.ml` changes only when required for the public contract.
- Implement lexer logic in `lib/lexer.ml` or `lib/lexer.mll`.
- Implement parser logic in `lib/parser.ml` or `lib/parser.mly`.
- Implement typed locations and error formatting in `lib/parse_error.ml`.
- Update `lib/dune` with separate module declarations.
- Keep `bin/main.ml` as the thin wrapper.
- Update `bin/dune` for the parse executable.
- Add lexical unit tests in `test/test_lexer.ml`.
- Add parser unit tests in `test/test_parser.ml`.
- Add error unit tests in `test/test_parse_errors.ml`.
- Add command black-box tests in `test/test_black_box_parse.ml`.
- Update `test/dune` for all test executables.
- Keep internal module imports directed toward leaf modules. Do not import a facade or coordinator from a leaf module.

### Verification

- Test every scenario from P01 through P27.
- Test stdout and stderr separately.
- Test exact exit statuses and error prefixes.
- Test stable byte offsets, lines, columns, kinds, and messages.
- Run Chicago-school tests against real domain objects.
- Inject in-memory file and output doubles into unit and integration tests.
- Run black-box tests against the real executable with child processes.
- Wait for process completion. Do not use static sleep delays.
- Use a maximum two-second timeout for each process operation.
- Test every command capability separately. The `parse` command requires dedicated success, missing-file, and extra-argument scenarios.
- Do not use network services, databases, sockets, or background brokers.
- No socket readiness polling applies because this story has no socket endpoint.
- Run `dune build` successfully.
- Run `dune runtest` successfully.
- Require a 100% pass rate with zero test failures.
- Treat lint output as advisory for this intermediate story.
- Verify that no stub, dummy success, ignored trailing input, mutable global parser state, or shell error masking exists.
- Ask whether an automated script would provide a faster and more reliable method before editing structured AST fixtures or test data manually.

### Forbidden implementation choices

- Do not implement evaluation, unification, stratification, safety checks, or result formatting.
- Do not print from lexer or parser library functions.
- Do not use regular expressions when they lose source locations.
- Do not use `pass`, ellipses, dummy values, unconditional success, or `|| true`.
- Do not add a network endpoint.
- Do not use the legacy `docker-compose` command. This story does not require Docker Compose.

## Validation commands

Run these commands from the repository root:

- `dune build`
- `dune runtest`
- `dune exec bin/main.exe -- parse test_suite/01_transitive_closure.dl`

Verify status 0 for valid input.

Verify status 1 for malformed input.

Verify status 2 for invalid command usage.

Verify stdout and stderr separately.

Verify exact success text and error prefixes.

## Dependencies

- Depends on: US-001
- Change type: new

```noctifab-contract
{
  "story_id": "US-002",
  "public_contracts": [
    {
      "id": "parse-file-command",
      "interface": "ocalogue parse <FILE>",
      "applicable_path_prefixes": ["bin/", "lib/", "test/"],
      "allowed_executables": ["ocalogue", "dune exec bin/main.exe --"],
      "exit_codes": [0, 1, 2],
      "stdout_contains": ["Parsed <N> clauses."],
      "stderr_prefixes": ["error: parse:", "error: usage:"]
    },
    {
      "id": "parser-library",
      "interface": "Parser.parse : string -> (Ast.program, Parse_error.t) result",
      "applicable_path_prefixes": ["lib/", "test/"],
      "allowed_executables": ["dune exec bin/main.exe --"],
      "exit_codes": [0, 1],
      "stdout_contains": [],
      "stderr_prefixes": []
    }
  ]
}
```