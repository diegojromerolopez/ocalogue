open Ocalogue_lib.Ast

let test_ast_construction () =
  let fact_atom = { predicate = "edge"; args = [ConstSymbol "a"; ConstSymbol "b"] } in
  let fact_clause = Fact fact_atom in
  match fact_clause with
  | Fact a ->
    assert (a.predicate = "edge");
    assert (string_of_atom a = "edge(a, b)")
  | _ -> assert false

let test_runner_cli () =
  let code = Ocalogue_lib.Runner.run_app [| "ocalogue"; "--version" |] in
  assert (code = 0)

let () =
  test_ast_construction ();
  test_runner_cli ();
  print_endline "[OK] Walking skeleton unit tests passed successfully."
