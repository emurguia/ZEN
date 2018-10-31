(* Ocamllex scanner for ZEN *)

{ open Parser }

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "#"     { comment lexbuf }            (* Comments *)
| '('      { LPAREN }
| ')'      { RPAREN }
| '{'      { LBRACE }
| '}'      { RBRACE }
| '['	   { LSQUARE }
| ']'	   { RSQUARE }
| ';'      { SEMI }
| ','      { COMMA }
| '+'      { PLUS }
| '-'      { MINUS }
| '*'      { TIMES }
| '/'      { DIVIDE }
| '='      { ASSIGN }
| "=="     { EQ }
| "!="     { NEQ }  
| '<'      { LT }
| "<="     { LEQ }
| ">"      { GT }
| ">="     { GEQ }
| "and"    { AND } 
| "or"     { OR } 
| "!"      { NOT }
| "if"     { IF }
| "else"   { ELSE }
| "for"    { FOR }
| "while"  { WHILE }
| "return" { RETURN }
| "int"    { INT }
| "float"  { FLOAT }
| "bool"   { BOOL }
| "true"   { TRUE }
| "false"  { FALSE }
| "list"   { LIST }
| "tuple"  { TUPLE }
| "void"   { VOID}
| ['0'-'9']+ as lxm { LITERAL(int_of_string lxm) }
| ['0'-'9']+'.'['0'-'9']+ as lxm { FLOAT_LITERAL(float_of_string lxm)}

| '"'([^'"']* as lxm)'"' { STRING_LITERAL(lxm) }

| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { ID(lxm) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }


and comment = parse
  "\n" { token lexbuf }
| _    { comment lexbuf }
