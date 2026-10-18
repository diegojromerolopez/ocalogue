type symbol = string

type term =
  | Var of string
  | ConstString of string
  | ConstInt of int
  | ConstSymbol of symbol
  | Wildcard

type atom = {
  predicate: symbol;
  args: term list;
}

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

let string_of_term = function
  | Var v -> v
  | ConstString s -> "\"" ^ s ^ "\""
  | ConstInt i -> string_of_int i
  | ConstSymbol s -> s
  | Wildcard -> "_"

let string_of_atom a =
  let args_str = String.concat ", " (List.map string_of_term a.args) in
  a.predicate ^ "(" ^ args_str ^ ")"
