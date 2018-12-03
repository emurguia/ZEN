%{ 
  open Ast 
  
  let first (a,_,_) = a;;
  let second (_,b,_) = b;;
  let third (_,_,c) = c;;
%}

%token INIT TURN END CLASS
%token GRID GRIDW GRIDH NULL
%token NEW ATTR COLON PERIOD MOVE
%token SEMI LPAREN RPAREN LBRACE RBRACE LSQUARE RSQUARE COMMA
%token RETURN IF ELSE FOR DO WHILE 
%token TITLE SIZE COLOR
%token INT FLOAT BOOL STRING COORD VOID
%token PLUS MINUS TIMES DIVIDE MOD ASSIGN NOT
%token EQ NEQ LT LEQ GT GEQ TRUE FALSE AND OR
%token <string> ID
%token <int> INT_LITERAL
%token <float> FLOAT_LITERAL
%token <string> STRING_LITERAL
%token EOF

%nonassoc NOELSE
%nonassoc ELSE
%right ASSIGN
%right COLON
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE MOD
%right NOT NEG
%left ACCESS

%start program
%type <Ast.program> program

%%

program:
  wflags decls EOF { (List.rev ($1), List.rev (first $2), List.rev (second $2), List.rev (third $2)) }

wflags:
   /* nothing */  { [] }
 | wflags wflag   { $2 :: $1 }

wflag:
   TITLE STRING_LITERAL                       { Title($2) }
 | SIZE INT_LITERAL INT_LITERAL               { Size($2, $3) }
 | COLOR INT_LITERAL INT_LITERAL INT_LITERAL  { Color($2, $3, $4) }

decls:
   /* nothing */      { [], [], [] } 
 | decls vdecl        { ($2 :: first $1), second $1, third $1 }
 | decls class_decl   { first $1, ($2 :: second $1), third $1 }
 | decls block        { first $1, second $1, ($2 :: third $1) }

typ:
    INT    { Int }
  | FLOAT  { Float }
  | BOOL   { Bool }
  | STRING { String }
  | COORD  { Coord }
  | VOID   { Void }

vdecl_list:  
  /* nothing */      { [] }
  | vdecl_list vdecl { $2 :: $1 }

vdecl: 
    typ ID SEMI       { PrimDecl($1, $2) }
  | LT ID GT ID SEMI  { ObjDecl($2, $4) }

class_decl:
  CLASS ID LBRACE attr_decl_list RBRACE 
  { { cname = $2; attributes = List.rev $4; } }

attr_decl_list:
    /* nothing */             { [] }
  | attr_decl_list attr_decl  { $2 :: $1 }

attr_decl:
  ATTR COLON typ ID SEMI { { atyp = $3; aname = $4; } }

/*
rule_decl_list:
    nothing                   { [] }
  | rule_decl_list rule_decl  { $2 :: $1 }

rule_decl:
  RULE COLON expr SEMI { { Expr $3 } }
*/

block:
    init_block  { $1 }
  | turn_block  { $1 }
  | end_block   { $1 }
  | fdecl_block { $1 }

init_block:
  INIT LBRACE vdecl_list stmt_list RBRACE 
  { { bname = "init"; btyp = Void; formals = []; locals = List.rev $3; body = List.rev $4 } }

turn_block:
  TURN LBRACE vdecl_list stmt_list RBRACE
  { { bname = "turn"; btyp = Void; formals = []; locals = List.rev $3; body = List.rev $4 } }

fdecl_block:
   typ ID LPAREN formals_opt RPAREN LBRACE vdecl_list stmt_list RBRACE
   { { btyp = $1; bname = $2; formals = $4; locals = List.rev $7; body = List.rev $8 } }

formals_opt:
    /* nothing */ { [] }
  | formal_list   { List.rev $1 }

formal_list:
    typ ID                   { [PrimDecl($1, $2)] }
  | formal_list COMMA typ ID { PrimDecl($3,$4) :: $1 }

end_block:
  END LBRACE vdecl_list stmt_list RBRACE
  { { bname = "end"; btyp = Int; formals = []; locals = List.rev $3; body = List.rev $4 } }

stmt_list:
    /* nothing */   { [] }
  | stmt_list stmt  { $2 :: $1 }

stmt:
    expr SEMI                               { Expr $1 }
  | RETURN SEMI                             { Return Noexpr }
  | RETURN expr SEMI                        { Return $2 }
  | LBRACE stmt_list RBRACE                 { Block(List.rev $2) }
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7) }
  | FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt
                                            { For($3, $5, $7, $9) }
  | DO stmt WHILE LPAREN expr RPAREN SEMI   { DoWhile($2, $5) }
  | WHILE LPAREN expr RPAREN stmt           { While($3, $5) }

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

expr:
    INT_LITERAL      { Literal($1) }
  | FLOAT_LITERAL    { FloatLit($1) }
  | STRING_LITERAL   { StringLit($1) }
  | TRUE             { BoolLit(true) }
  | FALSE            { BoolLit(false) }
  | obj              { $1 }
  | expr PLUS   expr { Binop($1, Add,   $3) }
  | expr MINUS  expr { Binop($1, Sub,   $3) }
  | expr TIMES  expr { Binop($1, Mult,  $3) }
  | expr DIVIDE expr { Binop($1, Div,   $3) }
  | expr MOD    expr { Binop($1, Mod,   $3) }
  | expr EQ     expr { Binop($1, Equal, $3) }
  | expr NEQ    expr { Binop($1, Neq,   $3) }
  | expr LT     expr { Binop($1, Less,  $3) }
  | expr LEQ    expr { Binop($1, Leq,   $3) }
  | expr GT     expr { Binop($1, Greater, $3) }
  | expr GEQ    expr { Binop($1, Geq,   $3) }
  | expr AND    expr { Binop($1, And,   $3) }
  | expr OR     expr { Binop($1, Or,    $3) }
  | MINUS expr %prec NEG              { Unop(Neg, $2) }
  | NOT expr                          { Unop(Not, $2) }
  | LPAREN expr RPAREN                { $2 }
  | obj ASSIGN expr                   { Assign($1, $3) }
  | NEW ID LPAREN actuals_opt RPAREN  { Instant($2, $4) }
  | ID LPAREN actuals_opt RPAREN      { Call($1, $3) }
  | LSQUARE expr COMMA expr RSQUARE   { CoordLit($2, $4) } 
  | ID LSQUARE ID RSQUARE             { CoordAccess($1, $3) }
  | GRIDW                             { GridCall("w") }
  | GRIDH                             { GridCall("h") }
  | NULL                              { Null }

obj:
    ID                                      { Id($1) }
  | ID PERIOD ID                            { Access($1, $3) }
  | GRID LSQUARE expr COMMA expr RSQUARE    { GridAccess($3, $5) }
  
actuals_opt:
    /* nothing */ { [] }
  | actuals_list  { List.rev $1 }

actuals_list:
    expr                    { [$1] }
  | actuals_list COMMA expr { $3 :: $1 }