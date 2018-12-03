open Ast

module StringMap = Map.Make(String)

(* Semantic checking of a program. Returns void if successful,
   throws an exception if something is wrong.

   Check each global variable, then check each special block *)

let check (flags, globals, classes, special_blocks) = 
  
  (* Method for finding duplicates *)
  let report_duplicate exceptf list =
    let rec helper = function
        n1 :: n2 :: _ when n1 = n2 -> raise (Failure (exceptf n1))
      | _ :: t -> helper t
      | [] -> ()
    in 
    helper (List.sort compare list)
  in

  (* Access types for objects *)
  let get_type ele = match ele with
    PrimDecl(t,_) -> t
  | ObjDecl(_,_) -> Void
  in 

  (* Method for checking that assignment is legal by comparing types on both sides *)
  (* let check_assign lvaluet rvaluet err = 
    if lvaluet == rvaluet then lvaluet else raise err
  in *)

  (**** Checking flags ****)
  let flag_check wflag = match wflag with
    Title(_) -> ()
  | Size(w,h) -> 
      if w <= 0 || h <= 0 then raise (Failure ("size cannot be less than or equal to 0"))
      else ()
  | Color(r,g,b) -> 
      if r > 255 || g > 255 || b > 255 || r < 0 || g < 0 || b < 0 then raise (Failure ("invalid RGB values for #color"))
      else ()
  in
  List.iter flag_check flags;

  (**** Checking globals ****)
  let check_gbl l g = match g with 
      PrimDecl(_,n) -> n :: l
      (* Major issue of getting the correct type of attribute back *)
    | ObjDecl(_,n) -> raise (Failure ("Cannot declare global object " ^ n)) 
  in

  let prims = List.fold_left check_gbl [] globals in
  
  (* check for duplicate globals *)
  report_duplicate (fun n -> "duplicate global variable " ^ n) prims;

  (* Checks for duplicate special blocks *)
  report_duplicate (fun n -> "duplicate blocks " ^ n) (List.map (fun block -> block.bname) special_blocks);

  (**** Classes ****)
  let class_decls =
    let class_decl m c =
      let name = c.cname in
      (* make map of attr name -> type *)
      let add_attr_typ map attr = 
        StringMap.add attr.aname attr.atyp map
      in
      let map_attr_typ = List.fold_left add_attr_typ StringMap.empty c.attributes in

      StringMap.add name map_attr_typ m 
    in
    (* create list of classes and their attrs mapped to attr names *)
    List.fold_left class_decl StringMap.empty classes
  in
  
  (* check that class decls are valid *)
  (* let check_obj_decl n =
    if StringMap.mem n class_decls then ()
    else raise (Failure ("class undefined"))
  in *)
  
  (*** Check for necessary code blocks ***)

  (* add built-in functions *)
  let built_in_decls = StringMap.add "tile" 
    { btyp = Void; bname = "tile"; formals = [PrimDecl(Int, "x"); PrimDecl(Int, "y")];
     locals = []; body = [] } 
    (StringMap.singleton "background" 
    { btyp = Void; bname = "background"; formals = [PrimDecl(String, "s")];
     locals = []; body = [] })
  in

  let built_in_decls = StringMap.add "capture"
    { btyp = Void; bname = "capture"; formals = [];
      locals = []; body = [] } built_in_decls
  in

  let built_in_decls = StringMap.add "setSprite"
    { btyp = Void; bname = "setSprite"; formals = [ObjDecl("type", "var"); PrimDecl(Int, "x")];
      locals = []; body = [] } built_in_decls
  in

  let built_in_decls = StringMap.add "isNull"
    { btyp = Int; bname = "isNull"; formals = [ObjDecl("type", "var")];
      locals = []; body = [] } built_in_decls
  in

  let built_in_decls = StringMap.add "iprint"
    { btyp = Void; bname = "iprint"; formals = [PrimDecl(Int, "x")];
      locals = []; body = [] } built_in_decls
  in

  let built_in_decls = StringMap.add "fprint"
    { btyp = Void; bname = "fprint"; formals = [PrimDecl(Float, "x")];
      locals = []; body = [] } built_in_decls
  in

  let built_in_decls = StringMap.add "sprint"
    { btyp = Void; bname = "sprint"; formals = [PrimDecl(String, "x")];
      locals = []; body = [] } built_in_decls
  in

  let built_in_decls = StringMap.add "close"
    { btyp = Void; bname = "close"; formals = [];
      locals = []; body = []} built_in_decls
  in 

  (* TO DO : 1. build a list of block decls and then 2. check for duplicates *)
  (* Create map of all functions - prevent duplicate function names *)
  let function_decls = List.fold_left (fun m fd -> StringMap.add fd.bname fd m) 
                       built_in_decls special_blocks
  in

  (* Find function or block given its function name *)
  let function_decl s = try StringMap.find s function_decls
    with Not_found -> raise (Failure ("unrecognized function or block " ^ s))
  in

  let check_function func =

    (* Type of each variable (global, formal, or local *)
    let (symbols,objects) = 
      let add_to_lists (s,o) x = match x with
          PrimDecl(_,n) -> (StringMap.add n (get_type x) s, o)
        | ObjDecl(c,n) -> (StringMap.add n (get_type x) s, StringMap.add n c o)
      in
      List.fold_left add_to_lists
      (StringMap.empty, StringMap.empty) (globals @ func.formals @ func.locals )
    in 

    (* Get class of object *)
    let class_of_obj s = try StringMap.find s objects with
      Not_found -> raise (Failure ("Object declaration of undefined class"))
    in

    let type_of_identifier s =
      try StringMap.find s symbols
      with Not_found -> raise (Failure ("undeclared identifier" ^ s))
    in

    (* Return the type of an expression or throw an exception *)
    let rec expr = function
      Literal _ -> Int
      | BoolLit _ -> Bool
      | FloatLit _ -> Float
      | StringLit _ -> String
      | Id s -> type_of_identifier s
      | Noexpr -> Void

      | CoordLit (x, y) -> let t1 = expr x and t2 = expr y in
        if t1 = Int && t2 = Int then Coord
        else raise (Failure ("expected integers for type coord"))
      | CoordAccess (_, a) -> 
        if a = "x" || a = "y" then Int
        else Coord

      | Binop(e1, op, e2) as e -> let t1 = expr e1 and t2 = expr e2 in
          (match op with
            Add | Sub | Mult | Div when t1 = Int && t2 = Int     -> Int
          | Add | Sub | Mult | Div when t1 = Int && t2 = Float   -> Float
          | Add | Sub | Mult | Div when t1 = Float && t2 = Int   -> Float
          | Add | Sub | Mult | Div when t1 = Float && t2 = Float -> Float
          | Equal | Neq when t1 = t2 -> Bool
          | Less | Leq | Greater | Geq when t1 = Int && t2 = Int   -> Bool
          | Less | Leq | Greater | Geq when t1 = Int && t2 = Float -> Bool
          | Less | Leq | Greater | Geq when t1 = Float && t2 = Int -> Bool
          | Less | Leq | Greater | Geq when t1 = Float && t2 = Float -> Bool
          | And | Or when t1 = Bool && t2 = Bool -> Bool
          | _ -> raise (Failure ("illegal binary operator " ^
                 string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                 string_of_typ t2 ^ " in " ^ string_of_expr e)))

      | Unop(op, e) as ex -> let t = expr e in
          (match op with
            Neg when t = Int -> Int
          | Neg when t = Float -> Float
          | Not when t = Bool -> Bool
          | _ -> raise (Failure ("illegal unary operator " ^ string_of_uop op ^
                 string_of_typ t ^ " in " ^ string_of_expr ex)))

      | Call(fname, _) -> 
        if fname = "capture" then Coord
        else let fd = function_decl fname in fd.btyp

      | Assign(le, re) as ex -> 
        (match re with 
          | Instant(c, _) ->
            (match le with 
              | Id (s) -> 
                let obj_class = class_of_obj s in
                if obj_class = c then Void
                else raise (Failure ("class mismatch: assignment " ^ obj_class ^ " to " ^ c))
              | _ -> raise (Failure ("must instantiate a variable of class " ^ c))
            )
          | _ -> 
            let t2 = expr re in
            let t1 = 
            (match le with
              | Id (s) -> type_of_identifier s 
              | Access (s1, s2) -> 
                if StringMap.mem s1 symbols then
                  let obj_class = class_of_obj s1 in
                  let attr_decls = StringMap.find obj_class class_decls in
                  if StringMap.mem s2 attr_decls then Void
                  else raise (Failure ("attribute does not exist"))
                else raise (Failure ("object was not declared"))
              | GridAccess (_,_) -> Void
              | _ -> expr le
            ) in
            if t2 == t1 then t2
            else raise (Failure ("Illegal assignment " ^ string_of_typ t1 ^ " = " ^ string_of_typ t2 ^ " in " ^ string_of_expr ex))
        )
            
      | GridCall (_) -> Int
      | GridAccess (_,_) -> Void
      | Access (s, a) ->
        if StringMap.mem s symbols then 
          let obj_class = class_of_obj s in
          let attr_decls = StringMap.find obj_class class_decls in
          if StringMap.mem a attr_decls then StringMap.find a attr_decls
          else raise (Failure ("attribute does not exist"))
        else raise (Failure ("object was not declared"))

      | Instant (_,_) -> Void

      | Null -> Void

    in

    let check_bool_expr e = if expr e != Bool 
    then raise (Failure ("expected Boolean expression in " ^ string_of_expr e))
    else () in

    (* Verify a statement or throw an exception *)
    let rec stmt = function
      Block sl -> let rec check_block = function
        [Return _ as s] -> stmt s
        | Block sl :: ss -> check_block (sl @ ss)
        | s :: ss -> stmt s ; check_block ss
        | [] -> ()
      in check_block sl
      | Expr e -> ignore (expr e)
      | Return e -> let t = expr e in if t = func.btyp then () else
         raise (Failure ("return gives " ^ string_of_typ t ^ " expected " ^
                         string_of_typ func.btyp ^ " in " ^ string_of_expr e))
           
      | If(p, b1, b2) -> check_bool_expr p; stmt b1; stmt b2
      | For(e1, e2, e3, st) -> ignore (expr e1); check_bool_expr e2;
                               ignore (expr e3); stmt st
      | While(p, s) -> check_bool_expr p; stmt s
      | DoWhile(s, p) -> check_bool_expr p; stmt s
    in

    stmt (Block func.body)

  in

  List.iter check_function special_blocks