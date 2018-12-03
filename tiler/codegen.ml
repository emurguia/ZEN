module L = Llvm
module A = Ast

module StringMap = Map.Make(String)

(* let print_map m =
  print_string ("Map:\n");
  let print_key k v =
    print_string (k ^ "\n")
  in
  StringMap.iter print_key m;; *)

let translate (wflags, globals, classes, blocks) = 
  let context = L.global_context () in
  let the_module = L.create_module context "Tiler" 
  and i32_t  = L.i32_type   context
  and i8_t   = L.i8_type    context
  and i1_t   = L.i1_type    context
  and flt_t  = L.double_type context
  and void_t = L.void_type  context in
  let str_t  = L.pointer_type i8_t in
  let obj_t  = L.pointer_type i8_t in

  let coord_t = L.named_struct_type context "coord_t" in
    L.struct_set_body coord_t [| i32_t; i32_t |] false;

  let ltype_of_typ = function
    A.Void -> void_t
    | A.Int -> i32_t
    | A.Bool -> i1_t
    | A.Float -> flt_t
    | A.String -> str_t
    | A.Coord -> coord_t
  in

  let get_init = function 
      A.Int -> L.const_int i32_t 0
    | A.Bool -> L.const_int i1_t 0
    | A.Float -> L.const_float flt_t 0.0
    | A.String -> L.const_pointer_null str_t
    | A.Coord -> L.const_named_struct coord_t [|L.const_int i32_t 0; L.const_int i32_t 0|]
    | _ -> L.const_int i32_t 0
  in

  (* Declare grid(), which the grid built-in function will call *)
  let createGrid_t = L.function_type void_t [| i32_t; i32_t |] in
  let createGrid_func = L.declare_function "createGrid" createGrid_t the_module in

  let setTitle_t = L.function_type void_t [| str_t |] in
  let setTitle_func = L.declare_function "setTitle" setTitle_t the_module in

  let setBackground_t = L.function_type void_t [| str_t |] in
  let setBackground_func = L.declare_function "setBackground" setBackground_t the_module in

  let setBackgroundColor_t = L.function_type void_t [| i32_t; i32_t; i32_t |] in
  let setBackgroundColor_func = L.declare_function "setBackgroundColor" setBackgroundColor_t the_module in

  let setWindow_t = L.function_type void_t [| i32_t; i32_t |] in
  let setWindow_func = L.declare_function "setWindow" setWindow_t the_module in

  let createGame_t = L.function_type void_t [| |] in
  let createGame_func = L.declare_function "createGame" createGame_t the_module in

  (* Game functions *)
  let init_type = L.function_type void_t [| |] in
  let setInit_t = L.function_type void_t [| L.pointer_type init_type |] in
  let setInit_func = L.declare_function "setInit" setInit_t the_module in

  let turn_type = L.function_type void_t [| |] in
  let setTurn_t = L.function_type void_t [| L.pointer_type turn_type |] in
  let setTurn_func = L.declare_function "setTurn" setTurn_t the_module in

  let end_type = L.function_type i32_t [| |] in
  let setEnd_t = L.function_type void_t [| L.pointer_type end_type |] in
  let setEnd_func = L.declare_function "setEnd" setEnd_t the_module in

  let runGame_t = L.function_type void_t [| |] in
  let runGame_func = L.declare_function "runGame" runGame_t the_module in

  (* Method for force closing windows, used mostly for testing purposes *)
  let closeGame_t = L.function_type void_t [| |] in 
  let closeGame_func = L.declare_function "closeGame" closeGame_t the_module in

  (* Grid functions *)
  let gridWidth_t = L.function_type i32_t [| |] in
  let gridWidth_func = L.declare_function "gridWidth" gridWidth_t the_module in

  let gridHeight_t = L.function_type i32_t [| |] in
  let gridHeight_func = L.declare_function "gridHeight" gridHeight_t the_module in

  let setGrid_t = L.function_type void_t [| obj_t; i32_t; i32_t|] in
  let setGrid_func = L.declare_function "setGrid" setGrid_t the_module in

  let getGrid_t = L.function_type obj_t [| i32_t; i32_t|] in
  let getGrid_func = L.declare_function "getGrid" getGrid_t the_module in

  (* Object functions *)
  let createObject_t = L.function_type obj_t [| obj_t |] in
  let createObject_func = L.declare_function "createObject" createObject_t the_module in

  let setSprite_t = L.function_type void_t [| obj_t; str_t|] in
  let setSprite_func = L.declare_function "setSprite" setSprite_t the_module in

  let getAttr_t = L.function_type obj_t [| obj_t |] in
  let getAttr_func = L.declare_function "getAttr" getAttr_t the_module in  

  let getX_t = L.function_type i32_t [||] in
  let getX_func = L.declare_function "getX" getX_t the_module in 

  let getY_t = L.function_type i32_t [||] in
  let getY_func = L.declare_function "getY" getY_t the_module in 

  let isNull_t = L.function_type i32_t [| obj_t |] in
  let isNull_func = L.declare_function "isNull" isNull_t the_module in 

  let getNullObject_t = L.function_type obj_t [||] in 
  let getNullObject_func = L.declare_function "createNullObject" getNullObject_t the_module in   

  (* Mouse function *)
  let getMouseCoords_t = L.function_type void_t [| obj_t |] in
  let getMouseCoords_func = L.declare_function "getMouseCoords" getMouseCoords_t the_module in

  (* Declare printf(), which the print built-in function will call *)
  let printf_t = L.var_arg_function_type i32_t [| str_t |] in
  let printf_func = L.declare_function "printf" printf_t the_module in

  (* Ensures int *)
  let ensureInt c = 
  if L.type_of c = flt_t then (L.const_fptosi c i32_t) else c in
   
  (* Ensures float *)
  let ensureFloat c = 
  if L.type_of c = flt_t then c else (L.const_sitofp c flt_t) in

  (* All global variables; remember its value in a map *)
  let global_vars =
    let global_var m decl =
      match decl with 
          A.PrimDecl(t, n) -> 
            let init = get_init t in
            StringMap.add n (L.define_global n init the_module) m
        | _ -> raise (Failure("can't define global objects")) 
    in
    List.fold_left global_var StringMap.empty globals 
  in

  (* make a class struct pointer *)
  let class_attr_decls =
    let class_decl m c =
      let name = c.A.cname in
      let add_attr_types m attr = 
        Array.append m [| ltype_of_typ attr.A.atyp |]
      in
      
      (* make array of just attr types *)
      let attr_types = List.fold_left add_attr_types [||] c.A.attributes in

      (* make map of attr name -> index *)
      let add_attr_idx (map, idx) attr = 
        (* get index of attr in list attr_types *)
        (StringMap.add attr.A.aname idx map, idx + 1)
      in
      let map_attr_idx = fst (List.fold_left add_attr_idx (StringMap.empty, 0) c.A.attributes) in
      
      (* make struct for class and associate list of (attr name, typ) with class *)
      let class_struct = L.named_struct_type context name in

      L.struct_set_body class_struct attr_types false;
      StringMap.add name (class_struct, map_attr_idx) m 
    in
    (* create list of structs for all classes *)
    List.fold_left class_decl StringMap.empty classes
  in

  (* TO DO: write class_rule_decls *)

  let block_decls =
    let block_decl m block =
      let name = block.A.bname in
      let map_types ta formal = 
        match formal with 
            A.PrimDecl(t, _) ->
              Array.append ta [| (ltype_of_typ t) |]
          | _ -> raise (Failure("invalid function formal"))
      in 
      let formal_types = List.fold_left map_types [||] block.A.formals in
      let btype = L.function_type (ltype_of_typ block.A.btyp) formal_types in
      StringMap.add name (L.define_function name btype the_module, block) m in
    List.fold_left block_decl StringMap.empty blocks 
  in

  (* declares the function to set window flags *)
  let flag_func_ptr = 
    let typ = L.function_type void_t [| |] in
    L.define_function "flags" typ the_module in

  (* builds the function to set window flags *)
  let flag_function_builder flags = 
    let builder = L.builder_at_end context (L.entry_block flag_func_ptr) in
      let flag_build wflag = (match wflag with
        A.Title(str) ->
          let title = L.build_global_stringptr str "title" builder in 
          ignore(L.build_call setTitle_func [| title |] "" builder)
      | A.Size(w,h) -> 
          let width = L.const_int i32_t w 
          and height = L.const_int i32_t h in
          ignore(L.build_call setWindow_func [| width; height |] "" builder)
      | A.Color(r,g,b) -> 
          let red = L.const_int i32_t r
          and green = L.const_int i32_t g
          and blue = L.const_int i32_t b in
      ignore(L.build_call setBackgroundColor_func [| red; green; blue |] "" builder)
      ) in
    List.iter flag_build flags;
    ignore(L.build_ret_void builder) 
  in

  let build_block_body block =
    let (the_block, _) = StringMap.find block.A.bname block_decls in
    let builder = L.builder_at_end context (L.entry_block the_block) in

    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)
    let local_vars =
      let add_formal m formal p = 
        match formal with 
            A.PrimDecl(t, n) ->
              L.set_value_name n p;
              let local = L.build_alloca (ltype_of_typ t) n builder in
              ignore (L.build_store p local builder);
              StringMap.add n local m 
          | A.ObjDecl(_,_) -> raise (Failure("invalid function formal"))
      in
      let formals = List.fold_left2 add_formal StringMap.empty block.A.formals (Array.to_list (L.params the_block)) in

      let add_local (m1, m2) decl =
        match decl with 
          A.PrimDecl(t, n) -> 
            let local_var = L.build_alloca (ltype_of_typ t) n builder in 
            (StringMap.add n local_var m1, m2)
        | A.ObjDecl(c, id) -> 
            let (cstruct, _) = StringMap.find c class_attr_decls in
            let cstruct_ptr = L.build_malloc cstruct (c ^ "_class_struct_ptr") builder in
            let cstruct_ptr = L.build_pointercast cstruct_ptr obj_t (c ^ "_ptrcast") builder in
            let obj_ptr = L.build_call createObject_func [| cstruct_ptr |] "" builder in
            let obj_ptr_ptr = L.build_alloca obj_t id builder in
            ignore(L.build_store obj_ptr obj_ptr_ptr builder);
            (m1, StringMap.add id (c, obj_ptr_ptr) m2)
      in
      List.fold_left add_local (formals, StringMap.empty) block.A.locals 
    in

    (* Return the value for a variable or formal argument *)
    let lookup_var n = try StringMap.find n (fst local_vars) with
      | Not_found -> try snd (StringMap.find n (snd local_vars)) with
      | Not_found -> try StringMap.find n global_vars with
      | Not_found -> raise (Failure("unknown variable name " ^ n))
    in

    let lookup_obj n = try StringMap.find n (snd local_vars) with
      | Not_found -> raise (Failure("unkown object name " ^ n))
    in

    (* Construct code for an expression; return its value *)
    let rec expr builder = function
        A.Literal i -> L.const_int i32_t i
      | A.BoolLit b -> L.const_int i1_t (if b then 1 else 0)
      | A.FloatLit f -> L.const_float flt_t f
      | A.StringLit s -> L.build_global_stringptr s "name" builder
     	| A.Noexpr -> L.const_int i32_t 0
      | A.CoordLit (e1, e2) -> 
          let e1' = ensureInt (expr builder e1)
          and e2' = ensureInt (expr builder e2) in
          let coord_ptr = L.build_alloca coord_t "tmp" builder in
          let x_ptr = L.build_struct_gep coord_ptr 0 "x" builder in
          ignore (L.build_store e1' x_ptr builder);
          let y_ptr = L.build_struct_gep coord_ptr 1 "y" builder in
          ignore (L.build_store e2' y_ptr builder);
          L.build_load coord_ptr "v" builder

      | A.CoordAccess (s1, s2) ->
        let coord_ptr = (lookup_var s1) in
          let idx = 
            (match s2 with
                "x" -> 0
              | "y" -> 1
              | _ -> raise (Failure("choose x or y to access coordinate"))
            )
          in
        let value_ptr = L.build_struct_gep coord_ptr idx (s2 ^ "_ptr") builder in
        L.build_load value_ptr s2 builder

      | A.GridAccess (e1, e2) -> 
        let e1' = expr builder e1
        and e2' = expr builder e2 in
        L.build_call getGrid_func [| e1'; e2' |] "accessed_obj" builder

      | A.Binop (e1, op, e2) ->
        let e1' = expr builder e1
        and e2' = expr builder e2 in
        if (L.type_of e1' = flt_t || L.type_of e2' = flt_t) then
          (match op with
            A.Add     -> L.build_fadd
          | A.Sub     -> L.build_fsub
          | A.Mult    -> L.build_fmul
          | A.Div     -> L.build_fdiv
          | A.Mod     -> L.build_frem
          | A.Equal   -> L.build_fcmp L.Fcmp.Oeq
          | A.Neq     -> L.build_fcmp L.Fcmp.One
          | A.Less    -> L.build_fcmp L.Fcmp.Olt
          | A.Leq     -> L.build_fcmp L.Fcmp.Ole
          | A.Greater -> L.build_fcmp L.Fcmp.Ogt
          | A.Geq     -> L.build_fcmp L.Fcmp.Oge
          | _         -> raise (Failure("invalid operands for floating point arguments")) 
          ) (ensureFloat e1') (ensureFloat e2') "tmp" builder 
        else
          (match op with
              A.Add     -> L.build_add
            | A.Sub     -> L.build_sub
            | A.Mult    -> L.build_mul
            | A.Div     -> L.build_sdiv
            | A.Mod     -> L.build_srem
            | A.And     -> L.build_and
            | A.Or      -> L.build_or
            | A.Equal   -> L.build_icmp L.Icmp.Eq
            | A.Neq     -> L.build_icmp L.Icmp.Ne
            | A.Less    -> L.build_icmp L.Icmp.Slt
            | A.Leq     -> L.build_icmp L.Icmp.Sle
            | A.Greater -> L.build_icmp L.Icmp.Sgt
            | A.Geq     -> L.build_icmp L.Icmp.Sge
          ) e1' e2' "tmp" builder

      | A.Unop(op, e) ->
        let e' = expr builder e in
        (match op with
            A.Neg     -> L.build_neg
          | A.Not     -> L.build_not) e' "tmp" builder

      | A.Assign (le, re) ->
        (match re with 
          | A.Instant(c, attrs) ->
            (match le with 
              | A.Id (s) ->
                let obj_ptr_ptr = lookup_var s in
                let obj_ptr = L.build_load obj_ptr_ptr "obj" builder in
                let cstruct_ptr = L.build_call getAttr_func [| obj_ptr |] "" builder in
                let (cstruct, _) = StringMap.find c class_attr_decls in
                let new_ptr = L.build_pointercast cstruct_ptr (L.pointer_type cstruct) (c ^ "_ptrcast") builder in
                ignore(List.fold_left (fun idx a -> 
                  let attr_ptr = L.build_struct_gep new_ptr idx (c ^ (string_of_int idx) ^ "_attr_ptr") builder in
                  ignore (L.build_store (expr builder a) attr_ptr builder);
                  idx + 1
                ) 0 attrs);
                obj_ptr

              | _ -> raise (Failure ("Must instantiate a variable"))
            )
          | _ -> let e' = expr builder re in
            (match le with 
              | A.Id (s) -> L.build_store e' (lookup_var s) builder
              | A.Access (s1, s2) -> 
                let (cname, obj_ptr_ptr) = lookup_obj s1 in
                let obj_ptr = L.build_load obj_ptr_ptr "obj" builder in
                let cstruct_ptr = L.build_call getAttr_func [| obj_ptr |] "" builder in
                let (cstruct, attr_idx) = StringMap.find cname class_attr_decls in
                let new_ptr = L.build_pointercast cstruct_ptr (L.pointer_type cstruct) (s1 ^ "_ptr") builder in
                let idx = StringMap.find s2 attr_idx in
                let attr_ptr = L.build_struct_gep new_ptr idx (s1 ^ "_" ^ s2 ^ "_attr_ptr") builder in  
                L.build_store e' attr_ptr builder;
              | A.GridAccess (e1, e2) ->
                let e1' = expr builder e1
                and e2' = expr builder e2 in
                ignore(L.build_call setGrid_func [| e'; e1'; e2' |] "" builder); e'
              | _ -> L.const_int i32_t 0
            )
        )

      | A.Id s -> L.build_load (lookup_var s) s builder

      | A.Call ("tile", [e1; e2]) ->
      	L.build_call createGrid_func [| (expr builder e1); (expr builder e2) |] "" builder

      | A.Call ("background", [e]) ->
        L.build_call setBackground_func [| (expr builder e) |] "" builder

      | A.Call ("setSprite", [e1; e2]) ->
        L.build_call setSprite_func [| (expr builder e1); (expr builder e2) |] "" builder

      | A.Call ("capture", []) ->
        let coord_ptr = L.build_alloca coord_t "tmp" builder in
        let void_ptr = L.build_pointercast coord_ptr (L.pointer_type i8_t) "tmp2" builder in

        let coord_ptr2 = 
          ignore(L.build_call getMouseCoords_func [| void_ptr |] "" builder);
          L.build_pointercast void_ptr (L.pointer_type coord_t) "c" builder 
        in
        L.build_load coord_ptr2 "v" builder

      | A.Call ("isNull", [e]) ->
        L.build_call isNull_func [| (expr builder e) |] "" builder

       (* Set of print functions that prints to stdout *)
      | A.Call ("iprint", [e]) -> 
        let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder in
        L.build_call printf_func [| int_format_str ; (expr builder e) |] "printf" builder
      | A.Call ("fprint", [e]) ->
        let flt_format_str = L.build_global_stringptr "%f\n" "fmt" builder in
        L.build_call printf_func [| flt_format_str ; (expr builder e) |] "printf" builder
      | A.Call ("sprint", [e]) ->
        let str_format_str = L.build_global_stringptr "%s\n" "fmt" builder in
        L.build_call printf_func [| str_format_str ; (expr builder e) |] "printf" builder

      | A.Call ("close", []) ->
        L.build_call closeGame_func [| |] "" builder 

      (* Non-defined functions are defined by this case *)
      | A.Call (f, act) ->
        let (fdef, block) = StringMap.find f block_decls in
        let actuals = List.rev (List.map (expr builder) (List.rev act)) in
        let result = (match block.A.btyp with A.Void -> "" | _ -> f ^ "_result") in
        L.build_call fdef (Array.of_list actuals) result builder

      | A.GridCall (s) ->
        if s = "w" then 
          L.build_call gridWidth_func [||] "gridw" builder
        else L.build_call gridHeight_func [||] "gridh" builder
        
      | A.Access (c, a) -> 
        let (cname, obj_ptr_ptr) = lookup_obj c in
        let obj_ptr = L.build_load obj_ptr_ptr "obj" builder in
        let cstruct_ptr = L.build_call getAttr_func [| obj_ptr |] "" builder in
        let (cstruct, attr_idx) = StringMap.find cname class_attr_decls in
        let new_ptr = L.build_pointercast cstruct_ptr (L.pointer_type cstruct) (c ^ "_ptrcast") builder in

        (match a with 
          | "x" -> L.build_call getX_func [||] "" builder  
          | "y" -> L.build_call getY_func [||] "" builder 
          | _ -> 
            let idx = StringMap.find a attr_idx in
            let attr_ptr = L.build_struct_gep new_ptr idx (c ^ "_" ^ a ^ "_attr_ptr") builder in  
            L.build_load attr_ptr ("load_" ^ a ^ "_attr") builder
        )
      | A.Instant (_,_) -> raise (Failure ("Instantation needs an assignment"))
        (* this is essentially meaningless in this context w/o LHS *)
      | A.Null -> L.build_call getNullObject_func [||] "" builder
    in

    (* Invoke "f builder" if the current block doesn't already
       have a terminal (e.g., a branch). *)
    let add_terminal builder f =
      match L.block_terminator (L.insertion_block builder) with
      Some _ -> ()
      | None -> ignore (f builder) in

    (* Build the code for the given statement; return the builder for
       the statement's successor *)
    let rec stmt builder = function
  		A.Block sl -> List.fold_left stmt builder sl
      | A.Expr e -> ignore (expr builder e); builder
      | A.Return e -> ignore (match block.A.btyp with
          A.Void -> L.build_ret_void builder
      | _ -> L.build_ret (expr builder e) builder); builder
      | A.If (predicate, then_stmt, else_stmt) ->
        let bool_val = expr builder predicate in
        let merge_bb = L.append_block context "merge" the_block in
          let then_bb = L.append_block context "then" the_block in
          add_terminal (stmt (L.builder_at_end context then_bb) then_stmt)
            (L.build_br merge_bb);

          let else_bb = L.append_block context "else" the_block in
          add_terminal (stmt (L.builder_at_end context else_bb) else_stmt)
            (L.build_br merge_bb);

        ignore (L.build_cond_br bool_val then_bb else_bb builder);
        L.builder_at_end context merge_bb

      | A.While (predicate, body) ->
        let pred_bb = L.append_block context "while" the_block in
        ignore (L.build_br pred_bb builder);

        let body_bb = L.append_block context "while_body" the_block in
        add_terminal (stmt (L.builder_at_end context body_bb) body)
          (L.build_br pred_bb);

        let pred_builder = L.builder_at_end context pred_bb in
        let bool_val = expr pred_builder predicate in

        let merge_bb = L.append_block context "merge" the_block in
        ignore (L.build_cond_br bool_val body_bb merge_bb pred_builder);
        L.builder_at_end context merge_bb

      | A.DoWhile (body, predicate) -> stmt builder
        ( A.Block [ A.Block [ body ] ; A.While(predicate, body) ] )

      | A.For (e1, e2, e3, body) -> stmt builder
      ( A.Block [A.Expr e1 ; A.While (e2, A.Block [body ; A.Expr e3]) ] )
    in

    (* Build the code for each statement in the function *)
    let builder = stmt builder (A.Block block.A.body) in

    (* Add a return if the last block falls off the end *)
    add_terminal builder (match block.A.btyp with
        A.Void -> L.build_ret_void
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0)
    ) in

  List.iter build_block_body blocks;
  flag_function_builder wflags;

  let main_ftype = L.function_type i32_t [| |] in 
  let main_function = L.define_function "main" main_ftype the_module in
  let main_builder = L.builder_at_end context (L.entry_block main_function) in
  ignore (L.build_call createGame_func [||] "" main_builder);
  ignore (L.build_call flag_func_ptr [| |] "" main_builder);
  let (init_func_ptr, _) = StringMap.find "init" block_decls in
  ignore (L.build_call setInit_func [| init_func_ptr |] "" main_builder);
  if (StringMap.mem "turn" block_decls)
    then let (turn_func_ptr, _) = StringMap.find "turn" block_decls in
      ignore (L.build_call setTurn_func [| turn_func_ptr |] "" main_builder);
    else ();
  if (StringMap.mem "end" block_decls)
    then let (end_func_ptr, _) = StringMap.find "end" block_decls in
      ignore (L.build_call setEnd_func [| end_func_ptr |] "" main_builder);
    else ();
  ignore (L.build_call runGame_func [| |] "" main_builder);
  ignore (L.build_ret (L.const_int i32_t 0) main_builder);

  the_module
