(* Semantically-checked Abstract Syntax Tree and functions for printing it *)

open Ast

type sexpr = typ * sx
and sx =
    SIntLiteral of int
  | SFloatLiteral of string
  | SBooleanLiteral of bool
  | SStringLiteral of string
  | STupleLiteral of sexpr * sexpr 
  (*| SArrayInit of string * sexpr
  | SArrayAssign of string * sexpr * sexpr
  | SArrayAccess of string * sexpr*)
  (*| SListLiteral of sexpr list*)
  | SArrayLiteral of sexpr list * typ
  | SArrayAccess of string * sexpr * typ
  | SArrayAssign of string * sexpr * sexpr
 (* | SArrayAccess of string * sexpr
  | SArrayAssign of string * sexpr * sexpr*)

(*   | SListLiteral of sexpr list*)
  | SId of string
  | SBinop of sexpr * op * sexpr
  | SUnop of uop * sexpr
  | SAssign of string * sexpr
  | SCall of string * sexpr list
  (* | SListAccess of string * sexpr *)
  (* | SListAssign of string * sexpr * sexpr  *)
  (* | STupleAccess of string * sexpr  *)
  | SNoexpr

type sstmt =
    SBlock of sstmt list
  | SExpr of sexpr
  | SReturn of sexpr
  | SIf of sexpr * sstmt * sstmt
  | SFor of sexpr * sexpr * sexpr * sstmt
  | SWhile of sexpr * sstmt

type sfunc_decl = {
    styp : typ;
    sfname : string;
    sformals : bind list;
    slocals : bind list;
    sbody : sstmt list;
  }

type sprogram = bind list * sfunc_decl list

(* Pretty-printing functions *)

let rec string_of_sexpr (t, e) =
  "(" ^ string_of_typ t ^ " : " ^ (match e with
    SIntLiteral(l) -> string_of_int l
  | SBooleanLiteral(true) -> "true"
  | SBooleanLiteral(false) -> "false"
  | SStringLiteral(s) -> s
  | SFloatLiteral(l) -> l
  | SArrayLiteral(el, t) -> string_of_typ t ^ "[" ^ String.concat ", " (List.map (fun e -> string_of_sexpr e) el) ^ "]"
  | SArrayAccess(a, e, t) -> string_of_typ t ^ " " ^ a ^ "[" ^ string_of_sexpr e ^ "]"
  (*| SArrayAssign(a, idx, e) -> a ^ "[" ^ string_of_sexpr idx ^ "]" ^ " = " ^ string_of_sexpr e*)


  (* | SListLiteral(li) -> "[" ^ List.fold_left(fun b a -> b ^ " " ^ string_of_sexpr a ^ ", ") "" li ^ "]" *)
  | STupleLiteral(e1, e2) -> "(" ^ string_of_sexpr e1 ^ ", " ^ string_of_sexpr e2 ^ ")"
  (*| SArrayLiteral(el) -> "[" ^ String.concat ", " (List.map (fun e -> string_of_sexpr e) el) ^ "]"*)

  (*| SArrayLiteral(len, l) -> string_of_int len ^ ": [" ^ String.concat ", " (List.map string_of_sexpr l) ^ "]"*)
  (*| SArrayAccess(id, idx) -> id ^ "[" ^ string_of_sexpr idx ^ "]"
  | SArrayAssign(id, idx, e) -> id ^ "[" ^ string_of_sexpr idx ^ "]" ^ " = " ^ string_of_sexpr e*)

  | SId(s) -> s
  | SBinop(e1, o, e2) ->
      string_of_sexpr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_sexpr e2
  | SUnop(o, e) -> string_of_uop o ^ string_of_sexpr e
  | SAssign(v, e) -> v ^ " = " ^ string_of_sexpr e
  (* | SListAccess(s, e) -> s ^ "[" ^ string_of_sexpr e ^ "]" *)
  (* | SListAssign(s, e1, e2) -> s ^ "[" ^ string_of_sexpr e1 ^ "] = " ^ string_of_sexpr e2 *)
  (* | STupleAccess(s1, s2) -> s1 ^ "[" ^ string_of_sexpr s2 ^ "]" *)
  | SCall(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_sexpr el) ^ ")"
  | SNoexpr -> ""
				  ) ^ ")"				     

let rec string_of_sstmt = function
    SBlock(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_sstmt stmts) ^ "}\n"
  | SExpr(expr) -> string_of_sexpr expr ^ ";\n";
  | SReturn(expr) -> "return " ^ string_of_sexpr expr ^ ";\n";
  | SIf(e, s, SBlock([])) ->
      "if (" ^ string_of_sexpr e ^ ")\n" ^ string_of_sstmt s
  | SIf(e, s1, s2) ->  "if (" ^ string_of_sexpr e ^ ")\n" ^
      string_of_sstmt s1 ^ "else\n" ^ string_of_sstmt s2
  | SFor(e1, e2, e3, s) ->
      "for (" ^ string_of_sexpr e1  ^ " ; " ^ string_of_sexpr e2 ^ " ; " ^
      string_of_sexpr e3  ^ ") " ^ string_of_sstmt s
  | SWhile(e, s) -> "while (" ^ string_of_sexpr e ^ ") " ^ string_of_sstmt s

let string_of_sfdecl fdecl =
  string_of_typ fdecl.styp ^ " " ^
  fdecl.sfname ^ "(" ^ String.concat ", " (List.map snd fdecl.sformals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_vdecl fdecl.slocals) ^
  String.concat "" (List.map string_of_sstmt fdecl.sbody) ^
  "}\n"

let string_of_sprogram (vars, funcs) =
  String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^
  String.concat "\n" (List.map string_of_sfdecl funcs)
