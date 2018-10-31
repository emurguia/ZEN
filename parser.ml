type token =
  | SEMI
  | LPAREN
  | RPAREN
  | LBRACE
  | RBRACE
  | LSQUARE
  | RSQUARE
  | COMMA
  | PLUS
  | MINUS
  | TIMES
  | DIVIDE
  | ASSIGN
  | NOT
  | EQ
  | NEQ
  | LT
  | LEQ
  | GT
  | GEQ
  | TRUE
  | FALSE
  | AND
  | OR
  | RETURN
  | IF
  | ELSE
  | FOR
  | WHILE
  | INT
  | BOOL
  | FLOAT
  | STRING
  | LIST
  | TUPLE
  | INT_LITERAL of (int)
  | FLOAT_LITERAL of (float)
  | STRING_LITERAL of (string)
  | ID of (string)
  | TUPLE_LITERAL of (tuple)
  | EOF

open Parsing;;
let _ = parse_error;;
# 4 "parser.mly"
open Ast
# 49 "parser.ml"
let yytransl_const = [|
  257 (* SEMI *);
  258 (* LPAREN *);
  259 (* RPAREN *);
  260 (* LBRACE *);
  261 (* RBRACE *);
  262 (* LSQUARE *);
  263 (* RSQUARE *);
  264 (* COMMA *);
  265 (* PLUS *);
  266 (* MINUS *);
  267 (* TIMES *);
  268 (* DIVIDE *);
  269 (* ASSIGN *);
  270 (* NOT *);
  271 (* EQ *);
  272 (* NEQ *);
  273 (* LT *);
  274 (* LEQ *);
  275 (* GT *);
  276 (* GEQ *);
  277 (* TRUE *);
  278 (* FALSE *);
  279 (* AND *);
  280 (* OR *);
  281 (* RETURN *);
  282 (* IF *);
  283 (* ELSE *);
  284 (* FOR *);
  285 (* WHILE *);
  286 (* INT *);
  287 (* BOOL *);
  288 (* FLOAT *);
  289 (* STRING *);
  290 (* LIST *);
  291 (* TUPLE *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  292 (* INT_LITERAL *);
  293 (* FLOAT_LITERAL *);
  294 (* STRING_LITERAL *);
  295 (* ID *);
  296 (* TUPLE_LITERAL *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\002\000\004\000\006\000\006\000\009\000\
\009\000\005\000\005\000\005\000\005\000\005\000\005\000\007\000\
\007\000\003\000\010\000\010\000\012\000\008\000\008\000\013\000\
\013\000\013\000\013\000\013\000\013\000\013\000\013\000\014\000\
\014\000\011\000\011\000\011\000\011\000\011\000\011\000\011\000\
\011\000\011\000\011\000\011\000\011\000\011\000\011\000\011\000\
\011\000\011\000\011\000\011\000\011\000\011\000\011\000\011\000\
\011\000\011\000\011\000\011\000\011\000\015\000\015\000\016\000\
\016\000\000\000"

let yylen = "\002\000\
\002\000\000\000\002\000\002\000\009\000\000\000\001\000\002\000\
\004\000\001\000\001\000\001\000\001\000\001\000\001\000\000\000\
\002\000\003\000\001\000\003\000\003\000\000\000\002\000\002\000\
\002\000\003\000\003\000\005\000\007\000\009\000\005\000\000\000\
\001\000\001\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
\003\000\003\000\003\000\003\000\003\000\002\000\002\000\003\000\
\004\000\006\000\004\000\005\000\003\000\000\000\001\000\001\000\
\003\000\002\000"

let yydefred = "\000\000\
\002\000\000\000\066\000\000\000\010\000\011\000\012\000\013\000\
\015\000\014\000\001\000\003\000\004\000\000\000\000\000\018\000\
\000\000\000\000\000\000\000\000\008\000\000\000\000\000\016\000\
\000\000\000\000\009\000\017\000\000\000\000\000\000\000\000\000\
\022\000\005\000\000\000\000\000\000\000\037\000\038\000\000\000\
\000\000\000\000\000\000\034\000\035\000\036\000\000\000\040\000\
\000\000\041\000\023\000\000\000\000\000\000\000\000\000\054\000\
\055\000\025\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\024\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\061\000\000\000\
\027\000\021\000\000\000\026\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\044\000\
\045\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\020\000\000\000\000\000\000\000\057\000\000\000\
\000\000\060\000\000\000\000\000\031\000\000\000\000\000\000\000\
\000\000\000\000\029\000\000\000\000\000\030\000"

let yydgoto = "\002\000\
\003\000\004\000\012\000\013\000\014\000\019\000\026\000\030\000\
\020\000\054\000\049\000\050\000\051\000\087\000\090\000\091\000"

let yysindex = "\014\000\
\000\000\000\000\000\000\001\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\239\254\005\255\000\000\
\171\000\243\254\071\255\073\255\000\000\075\255\171\000\000\000\
\043\255\171\000\000\000\000\000\044\255\093\255\084\255\219\255\
\000\000\000\000\219\255\219\255\219\255\000\000\000\000\054\255\
\098\255\103\255\104\255\000\000\000\000\000\000\021\255\000\000\
\001\255\000\000\000\000\026\001\132\255\105\255\115\001\000\000\
\000\000\000\000\148\000\219\255\219\255\219\255\219\255\219\255\
\219\255\000\000\219\255\219\255\219\255\219\255\219\255\219\255\
\219\255\219\255\219\255\219\255\219\255\219\255\000\000\219\255\
\000\000\000\000\219\255\000\000\044\001\131\001\109\255\062\001\
\131\001\108\255\112\255\098\001\131\001\047\255\047\255\000\000\
\000\000\159\001\159\001\192\255\192\255\192\255\192\255\147\001\
\252\255\080\001\000\000\016\000\219\255\016\000\000\000\219\255\
\100\255\000\000\096\255\168\000\000\000\131\001\219\255\016\000\
\219\255\131\001\000\000\123\255\016\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\124\255\000\000\000\000\125\255\000\000\000\000\000\000\000\000\
\000\000\171\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\056\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\128\255\000\000\
\000\000\000\000\000\000\000\000\138\255\000\000\137\255\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\049\255\000\000\000\000\
\006\255\000\000\141\255\000\000\148\255\104\000\128\000\000\000\
\000\000\046\255\101\255\192\000\216\000\240\000\008\001\140\255\
\064\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\080\000\000\000\210\255\000\000\000\000\070\255\000\000\000\000\
\142\255\179\255\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\000\000\124\000\000\000\040\000\000\000\000\000\119\000\
\000\000\076\000\224\255\000\000\232\255\041\000\000\000\000\000"

let yytablesize = 691
let yytable = "\052\000\
\011\000\066\000\055\000\056\000\057\000\016\000\017\000\059\000\
\064\000\067\000\068\000\069\000\070\000\064\000\001\000\071\000\
\072\000\073\000\074\000\075\000\076\000\015\000\063\000\077\000\
\078\000\021\000\064\000\085\000\086\000\088\000\089\000\092\000\
\093\000\065\000\094\000\095\000\096\000\097\000\098\000\099\000\
\100\000\101\000\102\000\103\000\104\000\105\000\046\000\106\000\
\046\000\033\000\055\000\033\000\046\000\046\000\058\000\032\000\
\018\000\069\000\070\000\035\000\046\000\046\000\025\000\036\000\
\053\000\029\000\053\000\037\000\046\000\046\000\053\000\053\000\
\065\000\022\000\038\000\039\000\116\000\065\000\024\000\118\000\
\023\000\027\000\031\000\115\000\016\000\117\000\122\000\053\000\
\086\000\044\000\045\000\046\000\047\000\048\000\032\000\123\000\
\033\000\034\000\035\000\060\000\126\000\047\000\036\000\047\000\
\061\000\062\000\037\000\047\000\047\000\109\000\111\000\082\000\
\119\000\038\000\039\000\047\000\047\000\040\000\041\000\112\000\
\042\000\043\000\120\000\047\000\047\000\125\000\006\000\007\000\
\044\000\045\000\046\000\047\000\048\000\032\000\019\000\033\000\
\081\000\035\000\032\000\062\000\052\000\036\000\052\000\063\000\
\032\000\037\000\052\000\052\000\056\000\028\000\056\000\053\000\
\038\000\039\000\056\000\056\000\040\000\041\000\107\000\042\000\
\043\000\124\000\052\000\052\000\000\000\000\000\000\000\044\000\
\045\000\046\000\047\000\048\000\022\000\000\000\022\000\022\000\
\022\000\000\000\000\000\058\000\022\000\058\000\000\000\000\000\
\022\000\058\000\058\000\000\000\000\000\000\000\000\000\022\000\
\022\000\000\000\000\000\022\000\022\000\000\000\022\000\022\000\
\067\000\068\000\069\000\070\000\000\000\000\000\022\000\022\000\
\022\000\022\000\022\000\028\000\000\000\028\000\028\000\028\000\
\000\000\000\000\000\000\028\000\032\000\000\000\000\000\028\000\
\035\000\000\000\000\000\000\000\036\000\000\000\028\000\028\000\
\037\000\000\000\028\000\028\000\000\000\028\000\028\000\038\000\
\039\000\000\000\000\000\000\000\000\000\028\000\028\000\028\000\
\028\000\028\000\000\000\000\000\000\000\000\000\044\000\045\000\
\046\000\047\000\048\000\000\000\067\000\068\000\069\000\070\000\
\000\000\000\000\071\000\072\000\073\000\074\000\075\000\076\000\
\000\000\032\000\077\000\033\000\000\000\035\000\000\000\000\000\
\000\000\036\000\000\000\000\000\000\000\037\000\005\000\006\000\
\007\000\008\000\009\000\010\000\038\000\039\000\000\000\000\000\
\040\000\041\000\000\000\042\000\043\000\000\000\000\000\000\000\
\000\000\000\000\000\000\044\000\045\000\046\000\047\000\048\000\
\039\000\000\000\039\000\000\000\000\000\000\000\039\000\039\000\
\039\000\039\000\039\000\039\000\000\000\000\000\039\000\039\000\
\039\000\039\000\039\000\039\000\000\000\000\000\039\000\039\000\
\059\000\000\000\059\000\000\000\000\000\000\000\059\000\059\000\
\059\000\059\000\059\000\059\000\000\000\000\000\059\000\059\000\
\059\000\059\000\059\000\059\000\000\000\000\000\059\000\059\000\
\042\000\000\000\042\000\000\000\000\000\000\000\042\000\042\000\
\042\000\042\000\000\000\000\000\000\000\000\000\042\000\042\000\
\042\000\042\000\042\000\042\000\000\000\000\000\042\000\042\000\
\043\000\000\000\043\000\000\000\000\000\000\000\043\000\043\000\
\043\000\043\000\000\000\000\000\000\000\000\000\043\000\043\000\
\043\000\043\000\043\000\043\000\084\000\000\000\043\000\043\000\
\000\000\000\000\000\000\000\000\067\000\068\000\069\000\070\000\
\000\000\000\000\071\000\072\000\073\000\074\000\075\000\076\000\
\121\000\000\000\077\000\078\000\000\000\000\000\000\000\000\000\
\067\000\068\000\069\000\070\000\000\000\000\000\071\000\072\000\
\073\000\074\000\075\000\076\000\000\000\000\000\077\000\078\000\
\048\000\000\000\048\000\000\000\000\000\000\000\048\000\048\000\
\005\000\006\000\007\000\008\000\009\000\010\000\048\000\048\000\
\048\000\048\000\048\000\048\000\000\000\000\000\048\000\048\000\
\049\000\000\000\049\000\000\000\000\000\000\000\049\000\049\000\
\000\000\000\000\000\000\000\000\000\000\000\000\049\000\049\000\
\049\000\049\000\049\000\049\000\000\000\000\000\049\000\049\000\
\050\000\000\000\050\000\000\000\000\000\000\000\050\000\050\000\
\000\000\000\000\000\000\000\000\000\000\000\000\050\000\050\000\
\050\000\050\000\050\000\050\000\000\000\000\000\050\000\050\000\
\051\000\000\000\051\000\000\000\000\000\000\000\051\000\051\000\
\000\000\000\000\000\000\000\000\000\000\000\000\051\000\051\000\
\051\000\051\000\051\000\051\000\079\000\000\000\051\000\051\000\
\000\000\080\000\067\000\068\000\069\000\070\000\000\000\000\000\
\071\000\072\000\073\000\074\000\075\000\076\000\108\000\000\000\
\077\000\078\000\000\000\000\000\067\000\068\000\069\000\070\000\
\000\000\000\000\071\000\072\000\073\000\074\000\075\000\076\000\
\110\000\000\000\077\000\078\000\000\000\000\000\067\000\068\000\
\069\000\070\000\000\000\000\000\071\000\072\000\073\000\074\000\
\075\000\076\000\114\000\000\000\077\000\078\000\000\000\000\000\
\067\000\068\000\069\000\070\000\000\000\000\000\071\000\072\000\
\073\000\074\000\075\000\076\000\000\000\000\000\077\000\078\000\
\113\000\000\000\067\000\068\000\069\000\070\000\000\000\000\000\
\071\000\072\000\073\000\074\000\075\000\076\000\000\000\000\000\
\077\000\078\000\083\000\067\000\068\000\069\000\070\000\000\000\
\000\000\071\000\072\000\073\000\074\000\075\000\076\000\000\000\
\000\000\077\000\078\000\067\000\068\000\069\000\070\000\000\000\
\000\000\071\000\072\000\073\000\074\000\075\000\076\000\000\000\
\000\000\077\000\078\000\067\000\068\000\069\000\070\000\000\000\
\000\000\071\000\072\000\073\000\074\000\075\000\076\000\067\000\
\068\000\069\000\070\000\000\000\000\000\000\000\000\000\073\000\
\074\000\075\000\076\000"

let yycheck = "\032\000\
\000\000\001\001\035\000\036\000\037\000\001\001\002\001\040\000\
\003\001\009\001\010\001\011\001\012\001\008\001\001\000\015\001\
\016\001\017\001\018\001\019\001\020\001\039\001\002\001\023\001\
\024\001\039\001\006\001\060\000\061\000\062\000\063\000\064\000\
\065\000\013\001\067\000\068\000\069\000\070\000\071\000\072\000\
\073\000\074\000\075\000\076\000\077\000\078\000\001\001\080\000\
\003\001\001\001\083\000\003\001\007\001\008\001\001\001\002\001\
\017\000\011\001\012\001\006\001\015\001\016\001\023\000\010\001\
\001\001\026\000\003\001\014\001\023\001\024\001\007\001\008\001\
\003\001\003\001\021\001\022\001\109\000\008\001\004\001\112\000\
\008\001\039\001\039\001\108\000\001\001\110\000\119\000\024\001\
\121\000\036\001\037\001\038\001\039\001\040\001\002\001\120\000\
\004\001\005\001\006\001\002\001\125\000\001\001\010\001\003\001\
\002\001\002\001\014\001\007\001\008\001\001\001\003\001\007\001\
\013\001\021\001\022\001\015\001\016\001\025\001\026\001\008\001\
\028\001\029\001\027\001\023\001\024\001\003\001\003\001\003\001\
\036\001\037\001\038\001\039\001\040\001\002\001\007\001\004\001\
\005\001\006\001\001\001\003\001\001\001\010\001\003\001\003\001\
\003\001\014\001\007\001\008\001\001\001\026\000\003\001\033\000\
\021\001\022\001\007\001\008\001\025\001\026\001\083\000\028\001\
\029\001\121\000\023\001\024\001\255\255\255\255\255\255\036\001\
\037\001\038\001\039\001\040\001\002\001\255\255\004\001\005\001\
\006\001\255\255\255\255\001\001\010\001\003\001\255\255\255\255\
\014\001\007\001\008\001\255\255\255\255\255\255\255\255\021\001\
\022\001\255\255\255\255\025\001\026\001\255\255\028\001\029\001\
\009\001\010\001\011\001\012\001\255\255\255\255\036\001\037\001\
\038\001\039\001\040\001\002\001\255\255\004\001\005\001\006\001\
\255\255\255\255\255\255\010\001\002\001\255\255\255\255\014\001\
\006\001\255\255\255\255\255\255\010\001\255\255\021\001\022\001\
\014\001\255\255\025\001\026\001\255\255\028\001\029\001\021\001\
\022\001\255\255\255\255\255\255\255\255\036\001\037\001\038\001\
\039\001\040\001\255\255\255\255\255\255\255\255\036\001\037\001\
\038\001\039\001\040\001\255\255\009\001\010\001\011\001\012\001\
\255\255\255\255\015\001\016\001\017\001\018\001\019\001\020\001\
\255\255\002\001\023\001\004\001\255\255\006\001\255\255\255\255\
\255\255\010\001\255\255\255\255\255\255\014\001\030\001\031\001\
\032\001\033\001\034\001\035\001\021\001\022\001\255\255\255\255\
\025\001\026\001\255\255\028\001\029\001\255\255\255\255\255\255\
\255\255\255\255\255\255\036\001\037\001\038\001\039\001\040\001\
\001\001\255\255\003\001\255\255\255\255\255\255\007\001\008\001\
\009\001\010\001\011\001\012\001\255\255\255\255\015\001\016\001\
\017\001\018\001\019\001\020\001\255\255\255\255\023\001\024\001\
\001\001\255\255\003\001\255\255\255\255\255\255\007\001\008\001\
\009\001\010\001\011\001\012\001\255\255\255\255\015\001\016\001\
\017\001\018\001\019\001\020\001\255\255\255\255\023\001\024\001\
\001\001\255\255\003\001\255\255\255\255\255\255\007\001\008\001\
\009\001\010\001\255\255\255\255\255\255\255\255\015\001\016\001\
\017\001\018\001\019\001\020\001\255\255\255\255\023\001\024\001\
\001\001\255\255\003\001\255\255\255\255\255\255\007\001\008\001\
\009\001\010\001\255\255\255\255\255\255\255\255\015\001\016\001\
\017\001\018\001\019\001\020\001\001\001\255\255\023\001\024\001\
\255\255\255\255\255\255\255\255\009\001\010\001\011\001\012\001\
\255\255\255\255\015\001\016\001\017\001\018\001\019\001\020\001\
\001\001\255\255\023\001\024\001\255\255\255\255\255\255\255\255\
\009\001\010\001\011\001\012\001\255\255\255\255\015\001\016\001\
\017\001\018\001\019\001\020\001\255\255\255\255\023\001\024\001\
\001\001\255\255\003\001\255\255\255\255\255\255\007\001\008\001\
\030\001\031\001\032\001\033\001\034\001\035\001\015\001\016\001\
\017\001\018\001\019\001\020\001\255\255\255\255\023\001\024\001\
\001\001\255\255\003\001\255\255\255\255\255\255\007\001\008\001\
\255\255\255\255\255\255\255\255\255\255\255\255\015\001\016\001\
\017\001\018\001\019\001\020\001\255\255\255\255\023\001\024\001\
\001\001\255\255\003\001\255\255\255\255\255\255\007\001\008\001\
\255\255\255\255\255\255\255\255\255\255\255\255\015\001\016\001\
\017\001\018\001\019\001\020\001\255\255\255\255\023\001\024\001\
\001\001\255\255\003\001\255\255\255\255\255\255\007\001\008\001\
\255\255\255\255\255\255\255\255\255\255\255\255\015\001\016\001\
\017\001\018\001\019\001\020\001\003\001\255\255\023\001\024\001\
\255\255\008\001\009\001\010\001\011\001\012\001\255\255\255\255\
\015\001\016\001\017\001\018\001\019\001\020\001\003\001\255\255\
\023\001\024\001\255\255\255\255\009\001\010\001\011\001\012\001\
\255\255\255\255\015\001\016\001\017\001\018\001\019\001\020\001\
\003\001\255\255\023\001\024\001\255\255\255\255\009\001\010\001\
\011\001\012\001\255\255\255\255\015\001\016\001\017\001\018\001\
\019\001\020\001\003\001\255\255\023\001\024\001\255\255\255\255\
\009\001\010\001\011\001\012\001\255\255\255\255\015\001\016\001\
\017\001\018\001\019\001\020\001\255\255\255\255\023\001\024\001\
\007\001\255\255\009\001\010\001\011\001\012\001\255\255\255\255\
\015\001\016\001\017\001\018\001\019\001\020\001\255\255\255\255\
\023\001\024\001\008\001\009\001\010\001\011\001\012\001\255\255\
\255\255\015\001\016\001\017\001\018\001\019\001\020\001\255\255\
\255\255\023\001\024\001\009\001\010\001\011\001\012\001\255\255\
\255\255\015\001\016\001\017\001\018\001\019\001\020\001\255\255\
\255\255\023\001\024\001\009\001\010\001\011\001\012\001\255\255\
\255\255\015\001\016\001\017\001\018\001\019\001\020\001\009\001\
\010\001\011\001\012\001\255\255\255\255\255\255\255\255\017\001\
\018\001\019\001\020\001"

let yynames_const = "\
  SEMI\000\
  LPAREN\000\
  RPAREN\000\
  LBRACE\000\
  RBRACE\000\
  LSQUARE\000\
  RSQUARE\000\
  COMMA\000\
  PLUS\000\
  MINUS\000\
  TIMES\000\
  DIVIDE\000\
  ASSIGN\000\
  NOT\000\
  EQ\000\
  NEQ\000\
  LT\000\
  LEQ\000\
  GT\000\
  GEQ\000\
  TRUE\000\
  FALSE\000\
  AND\000\
  OR\000\
  RETURN\000\
  IF\000\
  ELSE\000\
  FOR\000\
  WHILE\000\
  INT\000\
  BOOL\000\
  FLOAT\000\
  STRING\000\
  LIST\000\
  TUPLE\000\
  EOF\000\
  "

let yynames_block = "\
  INT_LITERAL\000\
  FLOAT_LITERAL\000\
  STRING_LITERAL\000\
  ID\000\
  TUPLE_LITERAL\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'decls) in
    Obj.repr(
# 36 "parser.mly"
            ( _1 )
# 414 "parser.ml"
               : Ast.program))
; (fun __caml_parser_env ->
    Obj.repr(
# 40 "parser.mly"
                 ( [], [] )
# 420 "parser.ml"
               : 'decls))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'decls) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'vdecl) in
    Obj.repr(
# 41 "parser.mly"
                ( (_2 :: fst _1), snd _1 )
# 428 "parser.ml"
               : 'decls))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'decls) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'fdecl) in
    Obj.repr(
# 42 "parser.mly"
                ( fst _1, (_2 :: snd _1) )
# 436 "parser.ml"
               : 'decls))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 8 : 'typ) in
    let _2 = (Parsing.peek_val __caml_parser_env 7 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 5 : 'formals_opt) in
    let _7 = (Parsing.peek_val __caml_parser_env 2 : 'vdecl_list) in
    let _8 = (Parsing.peek_val __caml_parser_env 1 : 'stmt_list) in
    Obj.repr(
# 46 "parser.mly"
     ( { fname = _1;
	 formals = _4;
	 locals = List.rev _7;
	 body = List.rev _8 } )
# 450 "parser.ml"
               : 'fdecl))
; (fun __caml_parser_env ->
    Obj.repr(
# 52 "parser.mly"
                  ( [] )
# 456 "parser.ml"
               : 'formals_opt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'formal_list) in
    Obj.repr(
# 53 "parser.mly"
                  ( List.rev _1 )
# 463 "parser.ml"
               : 'formals_opt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'typ) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 56 "parser.mly"
                             ( [(_1,_2)] )
# 471 "parser.ml"
               : 'formal_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'formal_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'typ) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 57 "parser.mly"
                             ( (_3,_4) :: _1 )
# 480 "parser.ml"
               : 'formal_list))
; (fun __caml_parser_env ->
    Obj.repr(
# 60 "parser.mly"
        ( Int )
# 486 "parser.ml"
               : 'typ))
; (fun __caml_parser_env ->
    Obj.repr(
# 61 "parser.mly"
         ( Bool )
# 492 "parser.ml"
               : 'typ))
; (fun __caml_parser_env ->
    Obj.repr(
# 62 "parser.mly"
          ( Float )
# 498 "parser.ml"
               : 'typ))
; (fun __caml_parser_env ->
    Obj.repr(
# 63 "parser.mly"
           ( String )
# 504 "parser.ml"
               : 'typ))
; (fun __caml_parser_env ->
    Obj.repr(
# 64 "parser.mly"
          ( Tuple )
# 510 "parser.ml"
               : 'typ))
; (fun __caml_parser_env ->
    Obj.repr(
# 65 "parser.mly"
         ( List )
# 516 "parser.ml"
               : 'typ))
; (fun __caml_parser_env ->
    Obj.repr(
# 68 "parser.mly"
                     ( [] )
# 522 "parser.ml"
               : 'vdecl_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'vdecl_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'vdecl) in
    Obj.repr(
# 69 "parser.mly"
                     ( _2 :: _1 )
# 530 "parser.ml"
               : 'vdecl_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'typ) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 73 "parser.mly"
               ( (_1, _2) )
# 538 "parser.ml"
               : 'vdecl))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 76 "parser.mly"
                        ( [ _1 ] )
# 545 "parser.ml"
               : 'val_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'val_list) in
    Obj.repr(
# 77 "parser.mly"
                        ( [ _1 ] @ _3 )
# 553 "parser.ml"
               : 'val_list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'val_list) in
    Obj.repr(
# 80 "parser.mly"
                             ( _2 )
# 560 "parser.ml"
               : 'list_literal))
; (fun __caml_parser_env ->
    Obj.repr(
# 84 "parser.mly"
                   ( [] )
# 566 "parser.ml"
               : 'stmt_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'stmt_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'stmt) in
    Obj.repr(
# 85 "parser.mly"
                   ( _2 :: _1 )
# 574 "parser.ml"
               : 'stmt_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 88 "parser.mly"
              ( Expr _1 )
# 581 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    Obj.repr(
# 89 "parser.mly"
                ( Return Noexpr )
# 587 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 90 "parser.mly"
                     ( Return _2 )
# 594 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'stmt_list) in
    Obj.repr(
# 91 "parser.mly"
                            ( Block(List.rev _2) )
# 601 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'stmt) in
    Obj.repr(
# 92 "parser.mly"
                                            ( If(_3, _5, Block([])) )
# 609 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : 'expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'stmt) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'stmt) in
    Obj.repr(
# 93 "parser.mly"
                                            ( If(_3, _5, _7) )
# 618 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 6 : 'expr_opt) in
    let _5 = (Parsing.peek_val __caml_parser_env 4 : 'expr) in
    let _7 = (Parsing.peek_val __caml_parser_env 2 : 'expr_opt) in
    let _9 = (Parsing.peek_val __caml_parser_env 0 : 'stmt) in
    Obj.repr(
# 95 "parser.mly"
     ( For(_3, _5, _7, _9) )
# 628 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'stmt) in
    Obj.repr(
# 96 "parser.mly"
                                  ( While(_3, _5) )
# 636 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    Obj.repr(
# 99 "parser.mly"
                  ( Noexpr )
# 642 "parser.ml"
               : 'expr_opt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 100 "parser.mly"
                  ( _1 )
# 649 "parser.ml"
               : 'expr_opt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 103 "parser.mly"
                     ( IntLit(_1) )
# 656 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : float) in
    Obj.repr(
# 104 "parser.mly"
                     ( FloatLit(_1) )
# 663 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 105 "parser.mly"
                     ( StringLit(_1) )
# 670 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 106 "parser.mly"
                     ( BoolLit(true) )
# 676 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 107 "parser.mly"
                     ( BoolLit(false) )
# 682 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 108 "parser.mly"
                     ( Id(_1) )
# 689 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : tuple) in
    Obj.repr(
# 109 "parser.mly"
                     ( TupleLit(_1) )
# 696 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'list_literal) in
    Obj.repr(
# 110 "parser.mly"
                     ( ListLit(_1) )
# 703 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 111 "parser.mly"
                     ( Binop(_1, Add,   _3) )
# 711 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 112 "parser.mly"
                     ( Binop(_1, Sub,   _3) )
# 719 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 113 "parser.mly"
                     ( Binop(_1, Mult,  _3) )
# 727 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 114 "parser.mly"
                     ( Binop(_1, Div,   _3) )
# 735 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 115 "parser.mly"
                     ( Binop(_1, Equal, _3) )
# 743 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 116 "parser.mly"
                     ( Binop(_1, Neq,   _3) )
# 751 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 117 "parser.mly"
                     ( Binop(_1, Less,  _3) )
# 759 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 118 "parser.mly"
                     ( Binop(_1, Leq,   _3) )
# 767 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 119 "parser.mly"
                     ( Binop(_1, Greater, _3) )
# 775 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 120 "parser.mly"
                     ( Binop(_1, Geq,   _3) )
# 783 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 121 "parser.mly"
                     ( Binop(_1, And,   _3) )
# 791 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 122 "parser.mly"
                     ( Binop(_1, Or,    _3) )
# 799 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 123 "parser.mly"
                         ( Unop(Neg, _2) )
# 806 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 124 "parser.mly"
                     ( Unop(Not, _2) )
# 813 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 125 "parser.mly"
                     ( Assign(_1, _3) )
# 821 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'actuals_opt) in
    Obj.repr(
# 126 "parser.mly"
                                 ( Call(_1, _3) )
# 829 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'expr) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 127 "parser.mly"
                                        ( ListAssign(_1, [_3], _6) )
# 838 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 128 "parser.mly"
                            ( ListAccess(_1, [_3]))
# 846 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 129 "parser.mly"
                                  ( TupleLit(_2, _4) )
# 854 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 130 "parser.mly"
                       ( _2 )
# 861 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 133 "parser.mly"
                  ( [] )
# 867 "parser.ml"
               : 'actuals_opt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'actuals_list) in
    Obj.repr(
# 134 "parser.mly"
                  ( List.rev _1 )
# 874 "parser.ml"
               : 'actuals_opt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 137 "parser.mly"
                            ( [_1] )
# 881 "parser.ml"
               : 'actuals_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'actuals_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 138 "parser.mly"
                            ( _3 :: _1 )
# 889 "parser.ml"
               : 'actuals_list))
(* Entry program *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let program (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Ast.program)
