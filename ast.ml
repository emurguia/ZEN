(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or | Mod

type uop = Neg | Not

type typ = 
  Int 
  | Bool 
  | Float  
  | Tuple  
  (*| Array of typ*)
  (*| List of typ*)
  | String 
  | Void

type bind = typ * string

type expr =
    IntLiteral of int
  | FloatLiteral of string
  | BooleanLiteral of bool
  | StringLiteral of string
  | TupleLiteral of expr * expr 
  (*| ArrayInit of string * expr
  | ArrayAssign of string * expr * expr
  | ArrayAccess of string * expr*)
  (*| ListLiteral of expr list *)
  (*| ArrayLiteral of int * expr list*)
  (* | ListLiteral of expr list *)
  | Id of string
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Assign of string * expr
  | Call of string * expr list
 (* | ArrayAccess of string * expr
  | ArrayAssign of string * expr * expr*)

  (* | ListAccess of string * expr *)
  (* | ListAssign of string * expr * expr  *)
  | Noexpr
  (*| ArrayInit of typ * string * expr
  | ArrayAccess of expr * expr
  | ArrayAssign of expr * expr * expr*)

type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | For of expr * expr * expr * stmt
  | While of expr * stmt

type func_decl = {
    typ : typ;
    fname : string;
    formals : bind list;
    locals : bind list;
    body : stmt list;
  }

type program = bind list * func_decl list

(* Pretty-printing functions *)

let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Equal -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "&&"
  | Or -> "||"
  | Mod -> "%"

let string_of_uop = function
    Neg -> "-"
  | Not -> "!"

let rec string_of_expr = function
    IntLiteral(l) -> string_of_int l
  | FloatLiteral(l) -> l
  | BooleanLiteral(true) -> "true"
  | BooleanLiteral(false) -> "false"
  | StringLiteral(s) -> s
  (* | ListLit(li) -> "[" ^ List.fold_left(fun b a -> b ^ " " ^ string_of_expr a ^ ", ") "" li ^ "]" *)
  | TupleLiteral(e1, e2) -> "(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  (*| ArrayLiteral(len, l) -> string_of_int len ^ ": [" ^ String.concat ", " (List.map string_of_expr l) ^ "]"*)
  | Id(s) -> s
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(v, e) -> v ^ " = " ^ string_of_expr e
 (* | ArrayAccess(id, idx) -> id ^ "[" ^ string_of_expr idx ^ "]"
  | ArrayAssign(id, idx, e) -> id ^ "[" ^ string_of_expr idx ^ "]" ^ " = " ^ string_of_expr e*)

  (* | ListAccess(s, e) -> s ^ "[" ^ string_of_expr e ^ "]" *)
  (* | ListAssign(s, e1, e2) -> s ^ "[" ^ string_of_expr e1 ^ "] = " ^ string_of_expr e2 *)

  (*| ArrayInit(t, n, e) -> "Array " ^ string_of_typ t ^ " " ^ n ^ " = " ^ " [" ^ string_of_expr e ^ "]"
  | ArrayAccess(arr_init, index) -> string_of_expr arr_init ^ "[" ^ string_of_expr index ^ "]"   
  (*| ArrayAssign(a,b,c) -> string_of_expr a ^ " [" ^string_of_expr b ^ "] = " ^ string_of_expr c*)*)
  | Call(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Noexpr -> ""

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^
      string_of_expr e3  ^ ") " ^ string_of_stmt s
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s

and string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | Float -> "float"
  (*| Array(t) -> "[" ^ string_of_typ t ^ "]"*)
  (*| Array(l,t) -> string_of_typ t ^ " [" ^ string_of_int l ^ "]"*)
  (* | List -> "list" *)
  | Tuple -> "tuple"
  | String -> "string"
  | Void -> "void"


let string_of_vdecl (t, id) = string_of_typ t ^ " " ^ id ^ ";\n"

let string_of_fdecl fdecl =
  string_of_typ fdecl.typ ^ " " ^
  fdecl.fname ^ "(" ^ String.concat ", " (List.map snd fdecl.formals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_vdecl fdecl.locals) ^
  String.concat "" (List.map string_of_stmt fdecl.body) ^
  "}\n"

let string_of_program (vars, funcs) =
  String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^
  String.concat "\n" (List.map string_of_fdecl funcs)

