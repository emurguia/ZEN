(* Semantic checking for the MicroC compiler *)

open Ast
open Sast

module StringMap = Map.Make(String)

(* Semantic checking of the AST. Returns an SAST if successful,
   throws an exception if something is wrong.

   Check each global variable, then check each function *)

let check (globals, functions) =

  (* Verify a list of bindings has no void types or duplicate names *)
  let check_binds (kind : string) (binds : bind list) =
    List.iter (function
	(Void, b) -> raise (Failure ("illegal void " ^ kind ^ " " ^ b))
      | _ -> ()) binds;
    let rec dups = function
        [] -> ()
      |	((_,n1) :: (_,n2) :: _) when n1 = n2 ->
	  raise (Failure ("duplicate " ^ kind ^ " " ^ n1))
      | _ :: t -> dups t
    in dups (List.sort (fun (_,a) (_,b) -> compare a b) binds)
  in

  (**** Check global variables ****)

  check_binds "global" globals;

  (**** Check functions ****)

  (* Collect function declarations for built-in functions: no bodies *)
  (*change add bind: typ = return tupe, fname name, formals is parameters*)
  (*functions that aren't from libraries, manually fill in in codegen with LLVM generated by OCaml*)
  let built_in_decls = 
    let add_bind map (name, ty) = StringMap.add name {
      typ = Void;
      fname = name; 
      formals = [(ty, "x")];
      locals = []; body = [] } map
    in let funct_map = List.fold_left add_bind StringMap.empty [ ("print", String);
    								 ("printf", Float);
    								 ("printi", Int);
                     ("printb", Bool);
                     ("printbig", Int);
                                ]
    in
  	let add_bind2 map (name, ty1, ty2, ty3, ty4) = StringMap.add name {
      typ = Int;
      fname = name; 
      formals = [(ty1, "x");(ty2, "y");(ty3, "height");(ty4, "width")];
      locals = []; body = [] } map
    in let funct_map2 = List.fold_left add_bind2 funct_map [
                               ("make_triangle", Int, Int, Int, Int);
                               ("make_rectangle", Int, Int, Int, Int);

                                ]
                                
    in
  	let add_bind3 map (name, ty1, ty2, ty3, ty4) = StringMap.add name {
      typ = Int;
      fname = name; 
      formals = [(ty1, "x");(ty2, "y");(ty3, "radius");(ty4, "vertices")];
      locals = []; body = [] } map
     in
     let funct_map3 = List.fold_left add_bind3 funct_map2 [
                               ("make_circle", Int, Int, Int, Int);
                                ]  

  
  in
  	let add_bind4 map (name, ty1, ty2) = StringMap.add name {
      typ = Void;
      fname = name; 
      formals = [(ty1, "x");(ty2, "y")];
      locals = []; body = [] } map
    in
    let funct_map4 = List.fold_left add_bind4 funct_map3 [
                               ("make_point", Int, Int);
                                ]  
                                                           
  in
  	let add_bind5 map (name, ty1, ty2, ty3, ty4) = StringMap.add name {
      typ = Void;
      fname = name; 
      formals = [(ty1, "x1");(ty2, "y1");(ty3, "x2");(ty4, "y2")];
      locals = []; body = [] } map
    in 
     let funct_map5 = List.fold_left add_bind5 funct_map4 [
                               ("make_line", Int, Int, Int, Int);
                                ]    
  in
    let add_bind6 map (name) = StringMap.add name {
      typ = Int;
      fname = name; 
      formals = [];
      locals = []; body = [] } map
    in 
     let funct_map6 = List.fold_left add_bind6 funct_map5 [
                               ("make_window");
                               ("close_window");
                                ]     
  in
    let add_bind7 map (name) = StringMap.add name {
      typ = Bool;
      fname = name; 
      formals = [];
      locals = []; body = [] } map
    in 
     let funct_map7 = List.fold_left add_bind7 funct_map6 [
                               ("keep_open");
                               ("render");
                                ]                                    
 
  
  in                             
  	let add_bind8 map (name, ty) = StringMap.add name {
      typ = Float;
      fname = name; 
      formals = [(ty, "tuple")];
      locals = []; body = [] } map
    in 
     let funct_map8 = List.fold_left add_bind8 funct_map7 [
                               ("getX", Tuple);
                               ("getY", Tuple)
                               ]
  in                             
    let add_bind9 map (name, ty) = StringMap.add name {
      typ = Void;
      fname = name; 
      formals = [(ty, "tuple")];
      locals = []; body = [] } map
    in 
      List.fold_left add_bind9 funct_map8 [
                               ("setX", Tuple);
                               ("setY", Tuple)
                               ]     
                             
    (*let add_bind8 map (name, ty1, ty2) = StringMap.add name {
      typ = Int;
      fname = name; 
      formals = [(ty1, "w");(ty2, "h")];
      locals = []; body = [] } map
    in 
     List.fold_left add_bind8 funct_map7 [
                               ("make_sdl_window", Int, Int);
                               
                               ]     *)

  (*commenting out list built in functions*)
  (*
  in
  let add_bind7 map (name, ty1, ty2) = StringMap.add name {
      typ = Int|String|Tuple|Float|Bool;
      fname = name; 
      formals = [(t1, "list");(ty2, "index")];
      locals = []; body = [] } map
    in
    let _ = List.fold_left add_bind7 StringMap.empty [
                               ("get", List, Int);
                                ]                             
  in
  let add_bind8 map (name, ty1, ty2) = StringMap.add name {
      typ = Void;
      fname = name; 
      formals = [(ty1, "list");(ty2, "index")];
      locals = []; body = [] } map
    in 
    let _ = List.fold_left add_bind8 StringMap.empty [
                               ("remove", List, Index);
                               ("add", List, Index)
                                ]                             
  in
let add_bind9 map (name, ty) = StringMap.add name {
      typ = Int;
      fname = name; 
      formals = [(ty, "list")];
      locals = []; body = [] } map
    in 
    let ) = List.fold_left add_bind9 StringMap.empty [
                               ("length", List);
                                ]                             
  *)
  
  (* Add function name to symbol table *)

in
  let add_func map fd = 
    let built_in_err = "function " ^ fd.fname ^ " may not be defined"
    and dup_err = "duplicate function " ^ fd.fname
    and make_err er = raise (Failure er)
    and n = fd.fname (* Name of the function *)
    in match fd with (* No duplicate functions or redefinitions of built-ins *)
         _ when StringMap.mem n built_in_decls -> make_err built_in_err
       | _ when StringMap.mem n map -> make_err dup_err  
       | _ ->  StringMap.add n fd map 
  in

  (* Collect all function names into one symbol table *)
  let function_decls = List.fold_left add_func built_in_decls functions
  in
  
  (* Return a function from our symbol table *)
  let find_func s = 
    try StringMap.find s function_decls
    with Not_found -> raise (Failure ("unrecognized function " ^ s))
  in

  let _ = find_func "main" in (* Ensure "main" is defined *)

  let check_function func =
    (* Make sure no formals or locals are void or duplicates *)
    check_binds "formal" func.formals;
    check_binds "local" func.locals;

    (* Raise an exception if the given rvalue type cannot be assigned to
       the given lvalue type *)
    (*I REMOVED THE ERROR CHECKING HERE TO MAKE ARRAYS WORK WE NEED TO FIX IT SOMEHOW*)
    let rec check_assign lvaluet rvaluet err = match rvaluet with
        Array(t1,_) -> (match t1 with
        Int -> check_assign t1 Int err
        | _ -> raise (Failure err))
      | _ -> if lvaluet = rvaluet then lvaluet else raise (Failure err)
    in 


    (* Build local symbol table of variables for this function *)
    let symbols = List.fold_left (fun m (ty, name) -> StringMap.add name ty m)
	                StringMap.empty (globals @ func.formals @ func.locals )
    in

    (* Return a variable from our local symbol table *)
    let type_of_identifier s =
      try StringMap.find s symbols
      with Not_found -> raise (Failure ("undeclared identifier " ^ s))
    in

    (*let check_arr_assign st e et =
      let type_of_arr arr_typ = 
        match arr_typ with 
          Array(typ, _) -> typ
          | _ -> raise (Failure("not array type"))
      in check_assign(type_of_arr st) et
      (Failure ("illegal assignment " ^ string_of_typ st ^ " = " ^
          string_of_typ et ^ " in " ^ string_of_expr e))

    in*)

    let access_type = function
    Array(t, _) -> t
    | _ -> raise (Failure("illegal array access"))

    in


    (* Return a semantically-checked expression, i.e., with a type *)
    let rec expr = function
        IntLiteral  l -> (Int, SIntLiteral l)
      | FloatLiteral l -> (Float, SFloatLiteral l)
      | BooleanLiteral l  -> (Bool, SBooleanLiteral l)
      | StringLiteral l -> (String, SStringLiteral l)
      | ArrayLiteral l -> check_array_types l
      | ArrayAccess(a, e) -> check_int_expr e; (type_of_identifier a, SArrayAccess(a, expr e, access_type (type_of_identifier a)))
      | ArrayAssign(var, idx, num) -> check_int_expr num; check_int_expr idx; (type_of_identifier var, SArrayAssign(var, expr idx, expr num))


      (*ignore(type_of_identifier s);
                                  ignore(expr e1);
                                  let st = type_of_identifier s
                                  and e2t = type_of_identifier (string_of_expr e2)

                                in (check_arr_assign st e2 e2t, SArrayAssign(s, expr e1, expr e2))*)
      (*| ArrayInit(typ, size) -> (type_of_identifier typ, SArrayInit (typ, (expr size)))*)
      (*| ListLiteral elist as e -> 
        let tlist = List.map (expr) elist in
        if (List.length tlist) = 0
        then (List(Any), SListLiteral tlist)
      else
        let  x = List.hd tlist in
        if List.for_all (fun t -> t = x) tlist
        then (List (type_of_identifier(string_of_expr(e))), SListLiteral tlist)
      else raise (Failure("types inconsistent in list"))*)

      (*| ArrayLiteral(l, s) as a -> let arr_type = List.fold_left (fun t1 e -> let t2 = snd (expr e) in
            if t1 == t2 then t1
            else raise (Failure("All array elements must be the same type ")))
            (snd (expr (List.hd (s)))) (List.tl s) in
            (if l == List.length s then 
              let s_s = List.map (fun e -> expr e) s in
              (Array(l, type_of_identifier(string_of_expr(List.hd s))), SArrayLiteral(l, s_s))
            else raise(Failure("Assigning length not working ")))*)
      | TupleLiteral (x, y) -> let t1 = expr x and t2 = expr y in
      (Tuple, STupleLiteral (t1, t2))
      (* | TupleAccess (s1, s2) ->  let t1 = expr s2 in (Float, STupleAccess(s1, t1)) *)
      (* map all elements in list to their sexpr version (int literal -> sintliteral, etc.))*)
(* 	| ListLiteral  el -> let t = List.fold_left
		(fun e1 e2 ->
		  if (e1 == expr e2) then
		    e1
		  else raise
		    (Failure("Multiple types inside a list "))
		)
        (expr (List.hd el)) (List.tl el)
    in (List, SListLiteral el) *)
      (* | ListLiteral l ->  List.Map (fun a -> SExpr (a)) l in (List, SListLiteral l) *)
      (*| ArrayInit(_, _, e1) -> let e_type = expr e1 in 
        if e1 != Int
        then (raise(Failure("Array length must be of type int")))
        else SIntLiteral
      | (ArrayAccess(e1, e2) as e) -> let e_type = expr e1 and e_val = expr e2 in
          (*if(e_val != SIntLiteral)
            then (raise(Failure("Array index must be of type int")))
          else*)
            (match e_type with
              | Int
              | String
              | Boolean
              | Float
              | _ -> (raise(Failure("Arrays can't be that type"))))*)

      | Noexpr     -> (Void, SNoexpr)
      | Id s       -> (type_of_identifier s, SId s)
      | Assign(var, e) as ex -> 
          let lt = type_of_identifier var
          and (rt, e') = expr e in
          let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^ 
            string_of_typ rt ^ " in " ^ string_of_expr ex
          in (check_assign lt rt err, SAssign(var, (rt, e')))
      | Unop(op, e) as ex -> 
          let (t, e') = expr e in
          let ty = match op with
            Neg when t = Int || t = Float -> t
          | Not when t = Bool -> Bool
          | _ -> raise (Failure ("illegal unary operator " ^ 
                                 string_of_uop op ^ string_of_typ t ^
                                 " in " ^ string_of_expr ex))
          in (ty, SUnop(op, (t, e')))
      | Binop(e1, op, e2) as e -> 
          let (t1, e1') = expr e1 
          and (t2, e2') = expr e2 in
          (* All binary operators require operands of the same type *)
          let same = t1 = t2 in
          (* Determine expression type based on operator and operand types *)
          let ty = match op with
            Add | Sub | Mult | Div when same && t1 = Int   -> Int
          | Add | Sub | Mult | Div when same && t1 = Float -> Float
          | Equal | Neq            when same               -> Bool
          | Less | Leq | Greater | Geq
                     when same && (t1 = Int || t1 = Float) -> Bool
          | And | Or when same && t1 = Bool -> Bool
          | Mod when same && t1 = Int -> Int
          | _ -> raise (
	      Failure ("illegal binary operator " ^
                       string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                       string_of_typ t2 ^ " in " ^ string_of_expr e))
          in (ty, SBinop((t1, e1'), op, (t2, e2')))
      | Call(fname, args) as call -> 
        
        (*let print_ex arg = print_endline (string_of_expr arg) in
        List.iter print_ex args ;*)
          let fd = find_func fname in
          let param_length = List.length fd.formals in
          if List.length args != param_length then
            raise (Failure ("expecting " ^ string_of_int param_length ^ 
                            " arguments in " ^ string_of_expr call))
          else let check_call (ft, _) e = 
            let (et, e') = expr e in 
            let err = "illegal argument found " ^ string_of_typ et ^
              " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e
            in (check_assign ft et err, e')
          in 
          let args' = List.map2 check_call fd.formals args

          in (*let str_args = List.map string_of_sexpr args' in
          let all_args = String.concat " " str_args in
           raise (Failure (all_args)); *)
          (fd.typ, SCall(fname, args'))

    and get_arr_type e = match e with
      IntLiteral(_) :: ss -> get_arr_type ss
      | [] -> Int
      | _ -> raise (Failure("arrays only ints"))

  

    and check_array_types e = 
      let t = get_arr_type e in
      let check_arr_el e = match e with 
        IntLiteral(i) -> if t == Int then expr(IntLiteral(i)) else expr(FloatLiteral(string_of_int i))
        | _ -> raise (Failure("arrays only ints"))
      in (Array (t, IntLiteral(List.length e)), SArrayLiteral(List.map check_arr_el e, Array(t, IntLiteral(List.length e))))

    and check_int_expr e = 
      let (t', e') = expr e
      and err = "expected Int expression in " ^ string_of_expr e
      in if t' != Int then raise (Failure err) else ignore e' 

    (*and get_assign_sexpr e1 e2 = 
      let se1 = match e1 with 
      ArrayAccess(_,_) -> expr e1 (*let e1 = (a, e) in SArrayAccess(a, expr e, access_type (type_of_identifier a))*)
      | _ -> raise (Failure ("can only array assign to array"))
    in 
    let se2 = expr e2 in
    let lt = ArrayLiteral se1 in
    let rt = IntLiteral se2 in
    match lt with 
    Array(_,_) -> if check_int_expr rt then SAssign(e1,se2) else raise (Failure ("illegal assignment"))*)

  in 

    let check_bool_expr e = 
      let (t', e') = expr e
      and err = "expected Boolean expression in " ^ string_of_expr e
      in if t' != Bool then raise (Failure err) else (t', e') 
    in

    

    (* Return a semantically-checked statement i.e. containing sexprs *)
    let rec check_stmt = function
        Expr e -> SExpr (expr e)
      | If(p, b1, b2) -> SIf(check_bool_expr p, check_stmt b1, check_stmt b2)
      | For(e1, e2, e3, st) ->
	  SFor(expr e1, check_bool_expr e2, expr e3, check_stmt st)
      | While(p, s) -> SWhile(check_bool_expr p, check_stmt s)
      | Return e -> let (t, e') = expr e in
        if t = func.typ then SReturn (t, e') 
        else raise (
	  Failure ("return gives " ^ string_of_typ t ^ " expected " ^
		   string_of_typ func.typ ^ " in " ^ string_of_expr e))
	    
	    (* A block is correct if each statement is correct and nothing
	       follows any Return statement.  Nested blocks are flattened. *)
      | Block sl -> 
          let rec check_stmt_list = function
              [Return _ as s] -> [check_stmt s]
            | Return _ :: _   -> raise (Failure "nothing may follow a return")
            | Block sl :: ss  -> check_stmt_list (sl @ ss) (* Flatten blocks *)
            | s :: ss         -> check_stmt s :: check_stmt_list ss
            | []              -> []
          in SBlock(check_stmt_list sl)

    in (* body of check_function *)
    { styp = func.typ;
      sfname = func.fname;
      sformals = func.formals;
      slocals  = func.locals;
      sbody = match check_stmt (Block func.body) with
	SBlock(sl) -> sl
      | _ -> raise (Failure ("internal error: block didn't become a block?"))
    }
  in (globals, List.map check_function functions)
