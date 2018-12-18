(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or | Mod

type uop = Neg | Not





type expr =
    IntLiteral of int
  | FloatLiteral of string
  | BooleanLiteral of bool
  | StringLiteral of string
  | TupleLiteral of expr * expr 
  | ArrayLiteral of expr list
  | ArrayAccess of string * expr
  | ArrayAssign of string * expr * expr
  | Id of string
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Assign of string * expr
  | Call of string * expr list
  (* | TupleAccess of string * expr (* tilers is string * string*) *)
  | Noexpr

  type typ = 
    Int 
  | Bool 
  | Float  
  | Tuple  
  | Array of typ * expr
  | String 
  | Void

type bind = typ * string

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
  | TupleLiteral(e1, e2) -> "(" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ ")"
  | ArrayLiteral(el) -> "[" ^ String.concat ", " (List.map (fun e -> string_of_expr e) el) ^ "]"

  | Id(s) -> s
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(a, e) -> a ^ " = " ^ string_of_expr e
  | ArrayAccess(a, e) -> a ^ "[" ^ string_of_expr e ^ "]"
  | ArrayAssign(a, e1, e2) -> a ^ "[" ^ string_of_expr e1 ^ "] = " ^ string_of_expr e2
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
  | Array(t, e) -> string_of_typ t ^ "[" ^ string_of_expr e ^ "]"
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

