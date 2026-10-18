# Task: Walking Skeleton: Build Setup and AST Characterization

- **ID**: `task-eb5a166b`
- **Story ID**: `US-001`
- **Status**: `PENDING`
- **Change Type**: `FEATURE`
- **Depends On**: `[]` 
- **Target Files**: `dune-project`, `Makefile`, `lib/dune`, `lib/ast.ml`, `bin/dune`, `bin/main.ml`, `test/dune`, `test/test_ocalogue.ml`

## Description

Inspect existing lib/ast.ml, lib/runner.ml, and test/test_ocalogue.ml files before any change. Create dune-project for OCaml 5.x. Create lib/dune, bin/dune, and test/dune build files. Define minimal immutable AST types in lib/ast.ml: symbol, term, atom, comp_op, literal, clause, program, exactly per the AST Contract. Use direct module imports only. Do not add index or facade modules. Create bin/main.ml as a placeholder thin wrapper under 15 lines. Write Makefile with build, test, clean, lint, format targets. Make build run `dune build`. Make test run `dune runtest`. Make clean run `dune clean`. Make lint run `dune build @check` and return its real exit status. Make format run `dune fmt` and return its real exit status. Do not mask any failure with `|| true` or `2>/dev/null`. Characterize existing AST behavior in test/test_ocalogue.ml. Write unit tests with explicit names for every constructor: Var, ConstString, ConstInt, ConstSymbol, Wildcard, atom, each comp_op value, each literal variant, each clause variant, and program. Test equality behavior, nested values, empty lists, empty strings, and large int boundary values. Make every failing assertion state the input, the expected result, and the observed result. Run `dune build` and `dune runtest` to confirm the skeleton compiles and passes.
