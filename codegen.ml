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
    L.struct_set_body tuple_t [| i32_t; i32_t|] false;

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
  in


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
 
  let make_window_t = L.function_type i32_t [||] in
  let make_window_func = L.declare_function "make_window" make_window_t the_module in

  let close_window_t = L.function_type i32_t [||] in
  let close_window_func = L.declare_function "close_window" close_window_t the_module in

  let keep_open_t = L.function_type i1_t [||] in
  let keep_open_func = L.declare_function "keep_open" keep_open_t the_module in

  let render_t = L.function_type i1_t [||] in 
  let render_func = L.declare_function "render" render_t the_module in

  (* Ensures int *)
  let ensureInt c = 
    if L.type_of c = float_t then (L.const_fptosi c i32_t) else c in 

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

    (* Construct code for an expression; return its value *)
    let rec expr builder ((_, e) : sexpr) = match e with
	      SIntLiteral i -> L.const_int i32_t i
      | SBooleanLiteral b -> L.const_int i1_t (if b then 1 else 0)
      | SFloatLiteral l -> L.const_float_of_string float_t l
      | SStringLiteral s -> L.build_global_stringptr s "name" builder
      | SArrayLiteral (l, t) -> L.const_array (ltype_of_typ t) (Array.of_list (List.map (expr builder) l))
      | SArrayAccess (s, e, _) -> L.build_load (get_array_acc_address s e builder) s builder
      | SArrayAssign (s, e1, e2) -> 
        let lsb = get_array_acc_address s e1 builder
                      in 
                      let rsb = expr builder e2 in
                      ignore (L.build_store rsb lsb builder); rsb   
      | STupleLiteral (x, y) -> 
        let x' = ensureInt (expr builder x)
        and y' = ensureInt (expr builder y) in
        let t_ptr = L.build_alloca tuple_t "tmp" builder in
        let x_ptr = L.build_struct_gep t_ptr 0 "x" builder in
        ignore (L.build_store x' x_ptr builder);
        let y_ptr = L.build_struct_gep t_ptr 1 "y" builder in
        ignore(L.build_store y' y_ptr builder);
        L.build_load (t_ptr) "t" builder   
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
      | STupleAccess (s1, s2) ->  
        let t_ptr = (lookup s1) in
        let value_ptr = L.build_struct_gep t_ptr s2 ( "t_ptr") builder in
        L.build_load value_ptr "t_ptr" builder
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

