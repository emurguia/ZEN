(* Code generation: translate takes a semantically checked AST and
produces LLVM IR

LLVM tutorial: Make sure to read the OCaml version of the tutorial

http://llvm.org/docs/tutorial/index.html

Detailed documentation on the OCaml LLVM library:

http://llvm.moe/
http://llvm.moe/ocaml/

*)

(* We'll refer to Llvm and Ast constructs with module names *)
module L = Llvm
module A = Ast
open Sast 

module StringMap = Map.Make(String)

(* Code Generation from the SAST. Returns an LLVM module if successful,
   throws an exception if something is wrong. *)
let translate (globals, functions) =
  let context    = L.global_context () in
  (* Add types to the context so we can use them in our LLVM code *)
  let i32_t      = L.i32_type    context
  and i8_t       = L.i8_type     context
  and i1_t       = L.i1_type     context
  and float_t    = L.double_type context
  and array_t    = L.array_type 
  and void_t     = L.void_type   context 
  (* Create an LLVM module -- this is a "container" into which we'll 
     generate actual code *)
  and the_module = L.create_module context "Zen" in

  let str_t = L.pointer_type i8_t in
  let tuple_t = L.named_struct_type context "tuple_t" in
    L.struct_set_body tuple_t [| float_t; float_t |] false;

  let int_lit_to_int = function
    A.IntLiteral(i) -> i | _ -> raise(Failure("arrays must be int")) 

  in
  (* Convert MicroC types to LLVM types *)
  let ltype_of_typ = function
      A.Int   -> i32_t
    | A.Bool  -> i1_t
    | A.Float -> float_t
    | A.Void  -> void_t
    | A.String -> str_t
    | A.Tuple -> tuple_t
    | A.Array(typ, size) -> (match typ with
                              A.Int -> array_t i32_t (int_lit_to_int size)
                              | _ -> raise(Failure("arrays must be int")))
    (*| A.List(t) -> L.pointer_type (ltype_of_typ t)*)
    (*| A.Array(l, t) -> L.array_type (ltype_of_typ t) l*)
  in

  (*let rec atype_of_typ = function
      i32_t -> A.Int
    | i1_t -> A.Bool
    | float_t -> A.Float
    | void_t -> A.Void
    | str_t -> A.String
    | tuple_t -> A.Tuple
    | array_t (typ, size)  -> A.Array(atype_of_typ typ, atype_of_typ size)

  in *)


  (* Declare each global variable; remember its value in a map *)
  let global_vars : L.llvalue StringMap.t =
    let global_var m (t, n) = 
      let init = match t with
          A.Float -> L.const_float (ltype_of_typ t) 0.0
        | _ -> L.const_int (ltype_of_typ t) 0
      in StringMap.add n (L.define_global n init the_module) m in
    List.fold_left global_var StringMap.empty globals in

  let printf_t : L.lltype = L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue = L.declare_function "printf" printf_t the_module in

  let printbig_t = L.function_type i32_t [| i32_t |] in
  let printbig_func = L.declare_function "printbig" printbig_t the_module in

  let make_triangle_t = L.function_type i32_t [| i32_t; i32_t; i32_t; i32_t |] in
  let make_triangle_func = L.declare_function "make_triangle" make_triangle_t the_module in

  let make_rectangle_t = L.function_type i32_t [| i32_t; i32_t; i32_t; i32_t |] in
  let make_rectangle_func = L.declare_function "make_rectangle" make_rectangle_t the_module in

  let make_circle_t = L.function_type i32_t [| i32_t; i32_t; i32_t; i32_t |] in
  let make_circle_func = L.declare_function "make_circle" make_circle_t the_module in

  let make_point_t = L.function_type i32_t [| i32_t; i32_t; |] in
  let make_point_func = L.declare_function "make_point" make_point_t the_module in

  let make_line_t = L.function_type i32_t [| i32_t; i32_t; i32_t; i32_t |] in
  let make_line_func = L.declare_function "make_line" make_line_t the_module in

  (* Ensures int *)
  (* let ensureInt c = 
  if L.type_of c = float_t then (L.const_fptosi c i32_t) else c in *)
   
  (* Ensures float *)
  let make_window_t = L.function_type i32_t [||] in
  let make_window_func = L.declare_function "make_window" make_window_t the_module in

  let close_window_t = L.function_type i32_t [||] in
  let close_window_func = L.declare_function "close_window" close_window_t the_module in

  let keep_open_t = L.function_type i1_t [||] in
  let keep_open_func = L.declare_function "keep_open" keep_open_t the_module in

  let render_t = L.function_type i1_t [||] in 
  let render_func = L.declare_function "render" render_t the_module in


  let ensureFloat c = 
    if L.type_of c = float_t then c else (L.const_sitofp c float_t) in


  (* Define each function (arguments and return type) so we can 
   * define it's body and call it later *)
  let function_decls : (L.llvalue * sfunc_decl) StringMap.t =
    let function_decl m fdecl =
      let name = fdecl.sfname
      and formal_types = 
	Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fdecl.sformals)
      in let ftype = L.function_type (ltype_of_typ fdecl.styp) formal_types in
      StringMap.add name (L.define_function name ftype the_module, fdecl) m in
    List.fold_left function_decl StringMap.empty functions in
  
  (* Fill in the body of the given function *)
  let build_function_body fdecl =
    let (the_function, _) = StringMap.find fdecl.sfname function_decls in
    let builder = L.builder_at_end context (L.entry_block the_function) in

    let str_format_str = L.build_global_stringptr "%s\n" "str_fmt" builder
    and float_format_str = L.build_global_stringptr "%g\n" "fmt" builder 
    and int_format_str = L.build_global_stringptr "%d\n" "int_fmt" builder in

    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)
    let local_vars =
      let add_formal m (t, n) p = 
        let () = L.set_value_name n p in
	let local = L.build_alloca (ltype_of_typ t) n builder in
        let _  = L.build_store p local builder in
	StringMap.add n local m 
      in

      (* Allocate space for any locally declared variables and add the
       * resulting registers to our map *)
      let add_local m (t, n) =
	let local_var = L.build_alloca (ltype_of_typ t) n builder
	in StringMap.add n local_var m 
      in

      let formals = List.fold_left2 add_formal StringMap.empty fdecl.sformals
          (Array.to_list (L.params the_function)) in
      List.fold_left add_local formals fdecl.slocals 
    in

   
    (* Return the value for a variable or formal argument. First check
     * locals, then globals *)
    let lookup n = try StringMap.find n local_vars
                   with Not_found -> StringMap.find n global_vars
    in

   

    

   (* let init_arr v s = let tp = L.element_type (L.type_of v) in
    let sz = L.size_of tp in
    let sz = L.build_intcast sz (i32_t) "" builder in
    let dt = L.build_bitcast (L.build_call calloc_func [|s;sz|] "" builder) tp ""
builder in
 L.build_store dt v builder
 in*)

    (* Construct code for an expression; return its value *)
    let rec expr builder ((_, e) : sexpr) = match e with
	      SIntLiteral i -> L.const_int i32_t i
      | SBooleanLiteral b -> L.const_int i1_t (if b then 1 else 0)
      | SFloatLiteral l -> L.const_float_of_string float_t l
      | SStringLiteral s -> L.build_global_stringptr s "name" builder
      | SArrayLiteral (l, t) -> L.const_array (ltype_of_typ t) (Array.of_list (List.map (expr builder) l))
      | SArrayAccess (s, e, _) -> L.build_load (get_array_acc_address s e builder) s builder
      | SArrayAssign (var, idx, num) -> 

        let idx_val = (expr builder idx) and num_val = (expr builder num)
      in let llname = var (*^ "[" ^ L.string_of_llvalue idx_val ^ "]"*) in
      let arr_ptr = lookup var in
      let arr_ptr_load = L.build_load arr_ptr var builder in
      let arr_get = L.build_in_bounds_gep arr_ptr_load [|idx_val|] llname builder
    in L.build_store num_val arr_get builder
     (*making this like pixelman assign*) (*| SArrayAssign (s, e1, e2) -> let lsb = (match s with 
                      SArrayAccess(s,e,_) -> get_array_acc_address s e builder
                      | _ -> raise (Failure ("Illegal assignment lvalue!")))
                      in 
                      let rsb = expr builder e1 in
                      ignore (L.build_stoer rsb lsb builder); rsb*)


      (*let e1' = expr builder e1 and e2' = expr builder e2 in
        let addr = lookup s in
          let ty = (type_of addr) in 
          if ty == array_t then (ty = A.Array(A.Int, Array.length (addr)) in (
            match ty with

        A.Array(t,_) -> 
            let arr_ptr = L.pointer_type (ltype_of_typ t) in
            let cast_ptr = L.build_bitcast addr arr_ptr "c_ptr" builder in
            let addr = L.build_in_bounds_gep cast_ptr (Array.make 1 e1') "elmt_addr" builder in
            ignore(L.build_store e2' addr builder); e2'
        | _ -> raise (Failure ("Array type wrong"))))

        else raise (Failure ("array assign for arrays"))*)

      (*| SArrayInit (v, s) -> let var = (lookup v) and size = (expr builder s) in init_arr var size*)
      | STupleLiteral (x, y) -> 
        let x' = ensureFloat (expr builder x)
        and y' = ensureFloat (expr builder y) in
        let t_ptr = L.build_alloca tuple_t "tmp" builder in
        let x_ptr = L.build_struct_gep t_ptr 0 "x" builder in
        ignore (L.build_store x' x_ptr builder);
        let y_ptr = L.build_struct_gep t_ptr 1 "y" builder in
        ignore(L.build_store y' y_ptr builder);
        L.build_load (t_ptr) "t" builder

        (* let tuple_ptr = L.build_alloca tuple_t "tmp" builder in
        let x_ptr = L.build_struct_gep tuple_ptr 0 "x" builder in
        ignore (L.build_store x x_ptr builder);
        let y_ptr = L.build_struct_gep tuple_ptr 1 "y" builder in
        ignore (L.build_store y y_ptr builder); *)
        (* L.build_load tuple_ptr "v" builder *)
      
      (*| SArrayLiteral(_, s), (A.Array(_, array_typ) as t) ->
          let const_array = L.const_array (ltype_of_typ array_typ) (Array.of_list (List.map (fun e-> expr builder true e) s)) in
          if loadval then const_array
        else (let arr_ref = L.build_alloca (ltype_of_typ t) "arr_prt" builder in
              ignore (L.build_store const_array arr_ref builder); arr_ref)*)
      
      (*| SListLiteral elist -> 
        if List.length elist == 0
        then raise (Failure "List cannot be empty")
        else
          let len = L.const_int i32_t (List.length elist) in
          elements = expr elist in
          let etype = L.type_of (List.hd elements) in 
          let len = List.length elist in
          let ptr = L.build_array_malloc
                    etype
                    (L.const_int i32_t num_elems)
                     
                     in

          ignore (List.fold_left 
                   (fun i elem ->
                     let ind = L.const_int i32_t i in
                     let eptr = L.build_gep ptr [|ind|]  in
                     llstore elem eptr;
                     i+1
                   ) 0 elements); (ptr)*)
          
      | SNoexpr -> L.const_int i32_t 0
      | SId s -> L.build_load (lookup s) s builder
      | SAssign (s, e) -> let e' = expr builder e in
                          let _  = L.build_store e' (lookup s) builder in e'
      | SBinop (e1, op, e2) ->
	  let (t, _) = e1
	  and e1' = expr builder e1
	  and e2' = expr builder e2 in
	  if t = A.Float then (match op with 
	    A.Add     -> L.build_fadd
	  | A.Sub     -> L.build_fsub
	  | A.Mult    -> L.build_fmul
	  | A.Div     -> L.build_fdiv 
	  | A.Equal   -> L.build_fcmp L.Fcmp.Oeq
	  | A.Neq     -> L.build_fcmp L.Fcmp.One
	  | A.Less    -> L.build_fcmp L.Fcmp.Olt
	  | A.Leq     -> L.build_fcmp L.Fcmp.Ole
	  | A.Greater -> L.build_fcmp L.Fcmp.Ogt
	  | A.Geq     -> L.build_fcmp L.Fcmp.Oge
    | A.Mod     -> L.build_srem
	  | A.And | A.Or ->
	      raise (Failure "internal error: semant should have rejected and/or on float")
	  ) e1' e2' "tmp" builder 
	  else (match op with
	  | A.Add     -> L.build_add
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
      | SUnop(op, e) ->
	  let (t, _) = e in
          let e' = expr builder e in
	  (match op with
	    A.Neg when t = A.Float -> L.build_fneg 
	  | A.Neg                  -> L.build_neg
          | A.Not                  -> L.build_not) e' "tmp" builder
(*       | STupleAccess (s1, s2) ->  
        let t_ptr = (lookup s1) and
        v_ptr = (expr builder s2) and 
        zero_ptr = L.build_global_stringptr "0" "zero_ptr" builder and 
        one_ptr =L.build_global_stringptr "1" "one_ptr" builder in 
        (* let e' = ensureInt (expr builder e) in *)
        
         let idx = 
            (match v_ptr with
                zero_ptr -> 0
              | one_ptr -> 1
              | _ -> raise (Failure("choose 0 or 1 to access tuple" ^ string_of_sexpr s2 ))
            )
          in
        let value_ptr = L.build_struct_gep t_ptr idx ( "t_ptr") builder in
        L.build_load value_ptr "t_ptr" builder *)
          (* | SCall("getY", [e]) ->  *) 
      (* | A.Not                  -> L.build_not) e' "tmp" builder *)
      | SCall ("printbig", [e]) ->
	  L.build_call printbig_func [| (expr builder e) |] "printbig" builder
      | SCall ("make_triangle", [e1; e2; e3; e4]) ->
    L.build_call make_triangle_func [| (expr builder e1); (expr builder e2); (expr builder e3); (expr builder e4)|] 
    "make_triangle" builder
      | SCall ("make_rectangle", [e1; e2; e3; e4]) ->
    L.build_call make_rectangle_func [| (expr builder e1); (expr builder e2); (expr builder e3); (expr builder e4)|] 
    "make_rectangle" builder
      | SCall ("make_circle", [e1; e2; e3; e4]) ->
    L.build_call make_circle_func [| (expr builder e1); (expr builder e2); (expr builder e3); (expr builder e4)|] 
    "make_circle" builder
      | SCall ("make_line", [e1; e2; e3; e4]) ->
    L.build_call make_line_func [| (expr builder e1); (expr builder e2); (expr builder e3); (expr builder e4)|] 
    "make_line" builder
      | SCall ("make_point", [e1; e2]) ->
    L.build_call make_point_func [| (expr builder e1); (expr builder e2); |] 
    "make_point" builder
      (* | SCall("get_num", [e]) ->
    L.build_call get_num_func [| (expr builder e) |] "get_num" builder *)
      (* | SCall("getX", [e]) -> 
        (* let t_ptr = (lookup ((e)))  in *)
        let value_ptr = L.build_struct_gep e 0 ("x_ptr") builder in
        L.build_load value_ptr "x" builder *)
          (* | SCall("getY", [e]) ->  *)
      | SCall ("make_window", []) ->
    L.build_call make_window_func [||] "make_window" builder
     | SCall ("close_window", []) ->
    L.build_call close_window_func [||] "close_window" builder
     | SCall ("keep_open", []) ->
    L.build_call keep_open_func [||] "keep_open" builder
    | SCall ("render", []) -> 
    L.build_call render_func [||] "render" builder 
      | SCall ("printf", [e]) -> 
	  L.build_call printf_func [| float_format_str ; (expr builder e) |]
	    "printf" builder
      | SCall("print", [e]) ->
    L.build_call printf_func [| str_format_str ; (expr builder e) |]
      "print" builder
      | SCall("printi", [e]) | SCall("printb", [e]) ->
    L.build_call printf_func [| int_format_str ; (expr builder e) |]
      "printi" builder
      | SCall (f, args) ->
         let (fdef, fdecl) = StringMap.find f function_decls in
	 let llargs = List.rev (List.map (expr builder) (List.rev args)) in
	 let result = (match fdecl.styp with 
                        A.Void -> ""
                      | _ -> f ^ "_result") in
         L.build_call fdef (Array.of_list llargs) result builder

    and  
     get_array_acc_address s e1 builder = L.build_gep (lookup s)
      [| (L.const_int i32_t 0); (expr builder e1) |] s builder
    in
    
    (* Each basic block in a program ends with a "terminator" instruction i.e.
    one that ends the basic block. By definition, these instructions must
    indicate which basic block comes next -- they typically yield "void" value
    and produce control flow, not values *)
    (* Invoke "instr builder" if the current block doesn't already
       have a terminator (e.g., a branch). *)
    let add_terminal builder instr =
                           (* The current block where we're inserting instr *)
      match L.block_terminator (L.insertion_block builder) with
	Some _ -> ()
      | None -> ignore (instr builder) in
	
    (* Build the code for the given statement; return the builder for
       the statement's successor (i.e., the next instruction will be built
       after the one generated by this call) *)
    (* Imperative nature of statement processing entails imperative OCaml *)
    let rec stmt builder = function
	SBlock sl -> List.fold_left stmt builder sl
        (* Generate code for this expression, return resulting builder *)
      | SExpr e -> let _ = expr builder e in builder 
      | SReturn e -> let _ = match fdecl.styp with
                              (* Special "return nothing" instr *)
                              A.Void -> L.build_ret_void builder 
                              (* Build return statement *)
                            | _ -> L.build_ret (expr builder e) builder 
                     in builder
      (* The order that we create and add the basic blocks for an If statement
      doesnt 'really' matter (seemingly). What hooks them up in the right order
      are the build_br functions used at the end of the then and else blocks (if
      they don't already have a terminator) and the build_cond_br function at
      the end, which adds jump instructions to the "then" and "else" basic blocks *)
      | SIf (predicate, then_stmt, else_stmt) ->
         let bool_val = expr builder predicate in
         (* Add "merge" basic block to our function's list of blocks *)
	 let merge_bb = L.append_block context "merge" the_function in
         (* Partial function used to generate branch to merge block *) 
         let branch_instr = L.build_br merge_bb in

         (* Same for "then" basic block *)
	 let then_bb = L.append_block context "then" the_function in
         (* Position builder in "then" block and build the statement *)
         let then_builder = stmt (L.builder_at_end context then_bb) then_stmt in
         (* Add a branch to the "then" block (to the merge block) 
           if a terminator doesn't already exist for the "then" block *)
	 let () = add_terminal then_builder branch_instr in

         (* Identical to stuff we did for "then" *)
	 let else_bb = L.append_block context "else" the_function in
         let else_builder = stmt (L.builder_at_end context else_bb) else_stmt in
	 let () = add_terminal else_builder branch_instr in

         (* Generate initial branch instruction perform the selection of "then"
         or "else". Note we're using the builder we had access to at the start
         of this alternative. *)
	 let _ = L.build_cond_br bool_val then_bb else_bb builder in
         (* Move to the merge block for further instruction building *)
	 L.builder_at_end context merge_bb

      | SWhile (predicate, body) ->
          (* First create basic block for condition instructions -- this will
          serve as destination in the case of a loop *)
	  let pred_bb = L.append_block context "while" the_function in
          (* In current block, branch to predicate to execute the condition *)
	  let _ = L.build_br pred_bb builder in

          (* Create the body's block, generate the code for it, and add a branch
          back to the predicate block (we always jump back at the end of a while
          loop's body, unless we returned or something) *)
	  let body_bb = L.append_block context "while_body" the_function in
          let while_builder = stmt (L.builder_at_end context body_bb) body in
	  let () = add_terminal while_builder (L.build_br pred_bb) in

          (* Generate the predicate code in the predicate block *)
	  let pred_builder = L.builder_at_end context pred_bb in
	  let bool_val = expr pred_builder predicate in

          (* Hook everything up *)
	  let merge_bb = L.append_block context "merge" the_function in
	  let _ = L.build_cond_br bool_val body_bb merge_bb pred_builder in
	  L.builder_at_end context merge_bb

      (* Implement for loops as while loops! *)
      | SFor (e1, e2, e3, body) -> stmt builder
	    ( SBlock [SExpr e1 ; SWhile (e2, SBlock [body ; SExpr e3]) ] )
    in

    (* Build the code for each statement in the function *)
    let builder = stmt builder (SBlock fdecl.sbody) in

    (* Add a return if the last block falls off the end *)
    add_terminal builder (match fdecl.styp with
        A.Void -> L.build_ret_void
      | A.Float -> L.build_ret (L.const_float float_t 0.0)
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

  List.iter build_function_body functions;
  the_module

