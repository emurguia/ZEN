(* Ocamllex scanner for tiler *)

{ open Parser }

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "/*"     { multi lexbuf }             (* Multi-Line Comments *)
| "//"     { single lexbuf }			(* Single Line Comments *)
| "init"   { INIT }
| "turn"   { TURN }
| "end"	   { END }
| "class"  { CLASS }
| "attr"   { ATTR }
| "new"    { NEW }
| "grid"   { GRID }
| "gridw"  { GRIDW }
| "gridh"  { GRIDH }
| "NULL"   { NULL }
| "#title" { TITLE }
| "#size"  { SIZE }
| "#color" { COLOR }
| '('      { LPAREN }
| ')'      { RPAREN }
| '{'      { LBRACE }
| '}'      { RBRACE }
| '['	   { LSQUARE }
| ']'	   { RSQUARE }
| ';'      { SEMI }
| ':'	   { COLON }
| ','      { COMMA }
| '.'	   { PERIOD }
| '+'      { PLUS }
| '-'      { MINUS }
| '*'      { TIMES }
| '/'      { DIVIDE }
| '%'	   { MOD }
| '='      { ASSIGN }
| "=="     { EQ }
| "!="     { NEQ }
| '<'      { LT }
| "<="     { LEQ }
| ">"      { GT }
| ">="     { GEQ }
| "&&"     { AND }
| "||"     { OR }
| "!"      { NOT }
| ">>" 	   { MOVE }
| "if"     { IF }
| "else"   { ELSE }
| "for"    { FOR }
| "do"	   { DO }
| "while"  { WHILE }
| "return" { RETURN }
| "int"    { INT }
| "float"  { FLOAT }
| "bool"   { BOOL }
| "string" { STRING }
| "coord"  { COORD }
| "void"   { VOID }
| "true"   { TRUE }
| "false"  { FALSE }
| ['0'-'9']+ as lxm { INT_LITERAL(int_of_string lxm) }
| ['0'-'9']*'.'['0'-'9']+ | ['0'-'9']+'.'['0'-'9']* as lxm { FLOAT_LITERAL(float_of_string lxm)}
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { ID(lxm) }
| '"'([^'"']* as lxm)'"' { STRING_LITERAL(lxm) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }
(* Ignoring contents between /* and */ of multi-line comments *)
and multi = parse
  "*/"     { token lexbuf }
| _        { multi lexbuf }


(* Ignoring content beyond // on the same line *)
and single = parse
  '\n'     { token lexbuf }
| _        { single lexbuf }

