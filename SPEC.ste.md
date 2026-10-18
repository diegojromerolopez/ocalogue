# ocalogue Specification

## 1. Product

Build `ocalogue`, a pure OCaml 5.x Datalog engine with Dune.
The engine computes the least fixed point of facts and rules.
Declaration order must not change the result.

Use immutable `Set` and `Map` values in core evaluation.
Do not use mutable state in AST, unification, stratification, or evaluation.
Use tail recursion where practical.

## 2. Required Repository Layout

Create these files and directories:

```text
dune-project
Makefile
lib/dune
lib/ast.ml
lib/types.ml
lib/relation.ml
lib/unification.ml
lib/stratify.ml
lib/semi_naive.ml
lib/engine.ml
lib/lexer.ml or lib/lexer.mll
lib/parser.ml or lib/parser.mly
bin/dune
bin/main.ml
test/dune
test/test_ocalogue.ml
test/test_ast.ml
test/test_lexer.ml
test/test_parser.ml
test/test_unification.ml
test/test_stratification.ml
test/test_semi_naive.ml
test/test_engine.ml
test/test_official_suite.ml
test_suite/01_transitive_closure.dl
test_suite/02_same_generation.dl
test_suite/03_stratified_negation.dl
test_suite/04_mutual_recursion.dl
test_suite/05_cyclic_termination.dl
test_suite/06_unification_filters.dl
test_suite/07_unstratified_negation_error.dl
```

Keep each file responsible for one module or test area.
Do not create a monolithic source or test file.
Keep `bin/main.ml` as a thin wrapper.

## 3. AST Contract

Use these types, with `Int64` for integer values:

```ocaml
type symbol = string

type term =
  | Var of string
  | ConstString of string
  | ConstInt of int64
  | ConstSymbol of symbol
  | Wildcard

type atom = { predicate: symbol; args: term list }
type comp_op = Eq | Neq | Lt | Le | Gt | Ge

type literal =
  | PosAtom of atom
  | NegAtom of atom
  | Comparison of term * comp_op * term

type clause =
  | Fact of atom
  | Rule of atom * literal list
  | Query of literal list

type program = clause list
```

A variable starts with an uppercase letter or underscore.
A single underscore creates a wildcard term.
A named underscore identifier remains a variable only when it has more characters.
A symbol starts with a lowercase letter and continues with lowercase letters, digits, or underscores.
A string uses double quotes and supports escaped double quotes and backslashes.
An integer uses a signed 64-bit decimal range.
Reject integer overflow.

## 4. Grammar and Comments

Implement this grammar:

```ebnf
program         ::= statement* EOF ;
statement       ::= fact | rule | query ;
fact            ::= atom "." ;
rule            ::= atom ":-" literal ("," literal)* "." ;
query           ::= "?-" literal ("," literal)* "." ;
literal         ::= ["not"] atom | comparison ;
comparison      ::= term comp_op term ;
comp_op         ::= "=" | "!=" | "<" | "<=" | ">" | ">=" ;
atom            ::= PREDICATE "(" [term ("," term)*] ")" ;
term            ::= VARIABLE | CONSTANT | WILDCARD ;
```

Support `%`, `//`, and `/* ... */` comments.
Reject unterminated block comments and strings.
Report line and column for lexical and parse errors.

## 5. Semantic Rules

Require every head variable, negated-atom variable, and comparison variable to occur in a positive relational atom.
Reject unsafe rules with error prefix `ERROR: UNSAFE_RULE`.

Reject inconsistent predicate arity with error prefix `ERROR: ARITY_MISMATCH`.
Reject invalid comparisons with error prefix `ERROR: INVALID_COMPARISON`.
Equality may compare terms of the same value type.
Ordering comparisons apply only to two integers or two strings.
Return false for an equality involving different value types.

Build a dependency graph from each head predicate to each body predicate.
Mark negated edges as negative.
Reject every directed cycle containing a negative edge.
Return error text beginning with `ERROR: NON_STRATIFIED_NEGATION`.
Exit with status 1 for this error.

Evaluate strata in topological order.
Complete one stratum before starting the next.
Use semi-naive evaluation for recursive positive rules.
Each recursive round must use one differential relation for each positive body position in turn.
Store full, current differential, and next differential relations as immutable values.
Stop when every next differential relation is empty.

Set semantics remove duplicate tuples.
Sort displayed tuples by predicate name and then lexicographic term order.
Sort query bindings by their complete displayed binding.

## 6. CLI Contract

Build an executable named `ocalogue`.
Use these commands:

```text
ocalogue run FILE
ocalogue run FILE -q "QUERY"
ocalogue run FILE -q "QUERY" --format=text
ocalogue run FILE -q "QUERY" --format=json
ocalogue test DIRECTORY
ocalogue repl
ocalogue --help
```

`run` evaluates queries in the file.
The `-q` option evaluates one additional query.
The default format is `text`.
Accept only `text` and `json` formats.

Print text bindings as one tuple per line.
Print no result lines when the result set is empty.
Print JSON in this exact shape:

```json
{"query":"path(a, Target)","bindings":[{"Target":"b"}],"count":1}
```

Emit compact JSON with escaped strings.
Use `count: 0` for an empty result.

Print errors to stderr.
Use error prefixes `ERROR: LEXER`, `ERROR: PARSER`, `ERROR: IO`, `ERROR: UNSAFE_RULE`, `ERROR: ARITY_MISMATCH`, `ERROR: INVALID_COMPARISON`, and `ERROR: NON_STRATIFIED_NEGATION`.
Use exit status 0 for success, 1 for program or evaluation errors, and 2 for CLI usage errors.
Do not print stack traces during normal CLI errors.

## 7. REPL Contract

Start with prompt `ocalogue> `.
Support `.help`, `.load FILE`, and `.quit`.
Accept facts, rules, and queries.
Keep asserted facts in the current in-memory session.
Recompute results after each assertion.
Print `Fact asserted: ...` after a valid fact.
Print `Loaded N facts, M rules.` after a valid load.
Print `Goodbye.` for `.quit`.
Print errors with the same `ERROR:` prefixes.

## 8. Official Fixtures

Create and run seven fixtures.
Verify these outcomes:

1. Transitive closure returns four paths from `a` to `e`.
2. Same generation returns the three specified tuples.
3. Stratified negation returns `unreachable(1, 4)`.
4. Mutual recursion returns `even(0)`, `even(2)`, and `even(4)`.
5. Cyclic input terminates and returns the three specified connected tuples.
6. Salary comparison returns Alice and Dave in Engineering.
7. The negative cycle fails with `ERROR: NON_STRATIFIED_NEGATION` and exit status 1.

## 9. Build and Test Commands

Create these Makefile targets:

```text
build: dune build
 test: dune runtest
 e2e: dune runtest
 lint: dune build @check
 format: dune fmt
 clean: dune clean
```

The `test` target must return status 1 when zero tests run.
The `e2e` target must execute real CLI scenarios for every command, flag, format, and official fixture.
Do not use `docker-compose`; this project does not require Docker services.
Do not mask errors with `|| true`, `set +e`, or equivalent shell constructs.

## 10. Testing Rules

Use real immutable domain values in Chicago-school tests.
Use in-memory stores and injected test doubles for external boundaries.
Do not use network services or external databases.
Each feature needs unit, integration, and black-box CLI coverage.
Each black-box process needs a maximum two-second timeout.
Assert exit status, stdout, stderr, ordering, and exact JSON fields.
Reject tautological tests and empty test bodies.
Ask whether a script can generate structured fixtures more reliably than manual editing.

## 11. Forbidden Practices

Do not add mutable core evaluation state.
Do not add external runtime dependencies without approval.
Do not add placeholder functions, `pass`, ellipses, `NotImplementedError`, or empty handlers.
Do not suppress compiler, test, or shell failures.
Do not require linter perfection before the final hardening story.
