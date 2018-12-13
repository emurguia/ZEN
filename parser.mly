/* Ocamlyacc parser for ZEN */

%{
open Ast
%}

%token SEMI LPAREN RPAREN LBRACE RBRACE LSQUARE RSQUARE COMMA
%token PLUS MINUS TIMES DIVIDE ASSIGN NOT 
%token EQ NEQ LT LEQ GT GEQ TRUE FALSE AND OR MOD
%token RETURN IF ELSE FOR WHILE INT BOOL FLOAT STRING VOID
%token TUPLE 
%token <int> INT_LITERAL
%token <float> FLOAT_LITERAL
%token <string> STRING_LITERAL
%token <string> ID
%token <float * float> TUPLE_LITERAL 
%token EOF

%nonassoc NOELSE
%nonassoc ELSE
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE MOD
%right NOT NEG

%start program
%type <Ast.program> program

%%

program:
  decls EOF { $1 }


decls:
   /* nothing */ { [], [] }
  | decls vdecl { (($2 :: fst $1), snd $1) } 
  | decls fdecl { (fst $1, ($2 :: snd $1)) }

fdecl:
   typ ID LPAREN formals_opt RPAREN LBRACE vdecl_list stmt_list RBRACE
     { { typ = $1;
      fname = $2;
      formals = List.rev $4;
      locals = List.rev $7;
      body = List.rev $8 } }

formals_opt:
    /* nothing */ { [] }
  | formal_list   { $1 }

formal_list:
    local_typ ID                   { [($1,$2)] }
  | formal_list COMMA local_typ ID { ($3,$4) :: $1 }

typ:
  INT { Int }
| BOOL { Bool }
| FLOAT { Float }
| STRING { String }
| TUPLE { Tuple } 
/*| LIST LSQUARE typ RSQUARE { List($3) } */
| VOID { Void }

local_typ:
    typ {$1}
  /*| local_typ LSQUARE INT_LITERAL RSQUARE { Array ($3, $1)}*/

vdecl_list:
    /* nothing */    { [] }
  | vdecl_list vdecl { $2 :: $1 }


vdecl:
   local_typ ID SEMI { ($1, $2) }

/* val_list:
    expr                { [ $1 ] }
  | expr COMMA val_list { [ $1 ] @ $3 } */

 
expr_list_opt:
    /* nothing */ { [] }
  | expr_list { List.rev $1 }

expr_list:
    expr { [$1] }
  | expr_list COMMA expr { $3 :: $1 }

 /*list_literal:
    LSQUARE expr_list_opt RSQUARE { ListLiteral($2) } */


stmt_list:
    /* nothing */  { [] }
  | stmt_list stmt { $2 :: $1 }

stmt:
    expr SEMI { Expr $1 }
  | RETURN SEMI { Return Noexpr }
  | RETURN expr SEMI { Return $2 }
  | LBRACE stmt_list RBRACE { Block(List.rev $2) }
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7) }
  | FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt
     { For($3, $5, $7, $9) }
  | WHILE LPAREN expr RPAREN stmt { While($3, $5) }

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

array_expr:
    expr    { [$1] }
  | array_expr COMMA expr { $3 :: $1 }

expr:
    INT_LITERAL      { IntLiteral($1) }
  | FLOAT_LITERAL    { FloatLiteral(string_of_float $1) }
  | STRING_LITERAL   { StringLiteral($1) }

  /*| ID ASSIGN LSQUARE expr RSQUARE    {ArrayInit($1, $4) }
  | ID LSQUARE expr RSQUARE ASSIGN expr    {ArrayAssign($1, $3, $6) }
  | ID LSQUARE expr RSQUARE    {ArrayAccess($1, $3) }*/

  | TRUE             { BooleanLiteral(true) }
  | FALSE            { BooleanLiteral(false) }
  | ID               { Id($1) }
  /*| LSQUARE array_expr RSQUARE        { ArrayLiteral(List.length $2, List.rev $2) }*/
 /* | TUPLE_LITERAL    { TupleLiteral($1) } */
  /* | list_literal     { ListLiteral($1) } */
  | expr PLUS   expr { Binop($1, Add,   $3) }
  | expr MINUS  expr { Binop($1, Sub,   $3) }
  | expr TIMES  expr { Binop($1, Mult,  $3) }
  | expr DIVIDE expr { Binop($1, Div,   $3) }
  | expr EQ     expr { Binop($1, Equal, $3) }
  | expr NEQ    expr { Binop($1, Neq,   $3) }
  | expr LT     expr { Binop($1, Less,  $3) }
  | expr LEQ    expr { Binop($1, Leq,   $3) }
  | expr GT     expr { Binop($1, Greater, $3) }
  | expr GEQ    expr { Binop($1, Geq,   $3) }
  | expr AND    expr { Binop($1, And,   $3) }
  | expr OR     expr { Binop($1, Or,    $3) }
  | expr MOD    expr { Binop($1, Mod, $3)}
  | MINUS expr %prec NEG { Unop(Neg, $2) }
  | NOT expr         { Unop(Not, $2) }
  | ID ASSIGN expr   { Assign($1, $3) }
  /*| ID LSQUARE expr RSQUARE ASSIGN expr   { ArrayAssign($1, $3, $6) }
  | ID LSQUARE expr RSQUARE     { ArrayAccess($1, $3) }*/
  | ID LPAREN actuals_opt RPAREN { Call($1, $3) }
  | LPAREN expr COMMA expr RPAREN { TupleLiteral($2,$4) } 
  | LPAREN expr RPAREN { $2 }
  
  /*| expr LSQUARE expr RSQUARE ASSIGN expr   { ArrayAssign($1, $3, $6)}
  | ARRAY typ ID arr_init                   { ArrayInit($2, $3, $4)}
  | expr arr_access                         { ArrayAccess($1, $2)}*/

  /*arr_init:

    | ASSIGN LSQUARE expr RSQUARE           { $3 }

  arr_access:

    | LSQUARE expr RSQUARE           { $2 }*/

actuals_opt:
    /* nothing */ { [] }
  | actuals_list  { List.rev $1 }

actuals_list:
    /*expr  vartype                  { [$1] }*/
  | actuals_list COMMA expr { $3 :: $1 }
