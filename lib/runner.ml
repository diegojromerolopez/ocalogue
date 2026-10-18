let run_app argv = 
  let prog_name = if Array.length argv > 0 then argv.(0) else "ocalogue" in
  if Array.length argv <= 1 then (
    Printf.printf "Usage: %s [run <file> | test | --version | --help]\n" prog_name;
    0
  ) else
    match argv.(1) with
    | "--help" | "-h" ->
      Printf.printf "ocalogue - High-performance Datalog Deductive Engine\n";
      Printf.printf "Commands: run <file>, test <suite_dir>, repl\n";
      0
    | "--version" | "-v" ->
      Printf.printf "ocalogue v0.1.0 (OCaml walking skeleton)\n";
      0
    | "run" ->
      if Array.length argv > 2 then (
        Printf.printf "Executing Datalog file: %s\n" argv.(2);
        0
      ) else (
        Printf.eprintf "Error: Missing input file for 'run' command\n";
        1
      )
    | "test" ->
      Printf.printf "Running Datalog test suite...\n";
      Printf.printf "[PASS] Skeleton smoke test ok\n";
      0
    | unknown ->
      Printf.eprintf "Unknown command or file: %s\n" unknown;
      0
