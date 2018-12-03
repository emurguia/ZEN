(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Mod | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or

type uop = Neg | Not

type typ = Int | Float | Bool | String | Coord | Void

type bind = 
    PrimDecl of typ * string 
  | ObjDecl of string * string

type expr =
    Literal of int
  | FloatLit of float
  | BoolLit of bool
  | StringLit of string
  | Id of string
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Assign of expr * expr
  | Access of string * string
  | Call of string * expr list
  | CoordLit of expr * expr
  | CoordAccess of string * string
  | Instant of string * expr list
  | GridAccess of expr * expr
  | GridCall of string
  | Null
  | Noexpr

type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt* stmt
  | For of expr * expr * expr * stmt
  | DoWhile of stmt * expr
  | While of expr * stmt

type block = {
  btyp: typ;
  bname : string;
  formals : bind list;
  locals: bind list;
  body : stmt list;
}

type attr_decl = {
  atyp: typ;
  aname: string;
}

(* type rule_decl = RuleSet of expr *)

type class_decl = {
  cname: string;
  attributes: attr_decl list;
}

type flag =
    Title of string
  | Size of int * int
  | Color of int * int * int

type program = flag list * bind list * class_decl list * block list

(* Pretty-printing functions *)

let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Mod -> "%"
  | Equal -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "&&"
  | Or -> "||"

let string_of_uop = function
    Neg -> "-"
  | Not -> "!"

let rec string_of_expr = function
    Literal(l) -> string_of_int l
  | FloatLit(l) -> string_of_float l
  | BoolLit(true) -> "true"
  | BoolLit(false) -> "false"
  | Id(s) -> s
  | StringLit(s) -> s
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(s, e) -> string_of_expr s ^ " = " ^ string_of_expr e
  | Call(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | CoordLit(e1, e2) -> "[" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ "]"  
  | CoordAccess(s1, s2) -> s1 ^ "." ^ s2
  | Instant(s, el) -> 
      "new " ^ s ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Access(s1, s2) -> s1 ^ "." ^ s2
  | GridAccess(e1, e2) -> "grid[" ^ string_of_expr e1 ^ ", " ^ string_of_expr e2 ^ "]"  
  | GridCall(s) -> "grid" ^ s
  | Null -> "NULL"
  | Noexpr -> ""

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n"
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^
      string_of_expr e3  ^ ") " ^ string_of_stmt s
  | DoWhile(s, e) -> "do " ^ string_of_stmt s ^ "while (" ^ string_of_expr e ^ ")" ^ ";\n";
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s

let string_of_typ = function
    Int    -> "int"
  | Float  -> "float"
  | Bool   -> "bool"
  | String -> "string" 
  | Coord  -> "coord"
  | Void   -> "void" 

let string_of_flag = function
    Title(title) -> "title: " ^ title ^ "\n"
  | Size(w, h) -> "size: " ^ string_of_int w ^ "x" ^ string_of_int h ^ "\n"
  | Color(r, g, b) -> "color: " ^ string_of_int r ^ ", " ^ string_of_int g ^ ", " ^ string_of_int b ^ "\n"

let string_of_vdecl = function
    PrimDecl(t, id) -> string_of_typ t ^ " " ^ id ^ ";\n"
  | ObjDecl(id1, id2) -> "<" ^ id1 ^ "> " ^ id2 ^ ";\n"

let string_of_attr attr = "attr: " ^ string_of_typ attr.atyp ^ " " ^ attr.aname ^ ";\n"

(* let string_of_rule = function
  RuleSet(e) -> "rule: " ^ string_of_expr e ^ ";\n" *)

let string_of_block block =
  string_of_typ block.btyp ^ " " ^
  (* block.bname ^ "(" ^ String.concat ", " (List.map snd block.formals) ^ ")\n{\n" ^ *)
  String.concat "" (List.map string_of_vdecl block.locals) ^
  String.concat "" (List.map string_of_stmt block.body) ^
  "}\n"

let string_of_classdecl cdecl = 
  "class " ^ cdecl.cname ^ "{\n" ^
  String.concat "" (List.map string_of_attr cdecl.attributes) ^
  (* String.concat "" (List.map string_of_rule cdecl.rules) ^ *)
  "}\n"

let string_of_program (flags, vars, classes, funcs) =
  String.concat "" (List.map string_of_flag flags) ^ "\n" ^
  String.concat "\n" (List.map string_of_vdecl vars) ^ "\n" ^  
  String.concat "" (List.map string_of_classdecl classes) ^ "\n" ^ 
  String.concat "\n" (List.map string_of_block funcs)