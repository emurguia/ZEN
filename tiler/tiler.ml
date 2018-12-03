(* Top-level of the Tiler compiler: scan & parse the input,
   check the resulting AST, generate LLVM IR, and dump the module *)

open Printf

module StringMap = Map.Make(String)

type action = Ast | LLVM_IR | Compile

let _ =
  let action = 
  if Array.length Sys.argv > 1 then
    List.assoc Sys.argv.(1) [
            ("-a", Ast);      (* Print the AST *)
            ("-l", LLVM_IR);  (* Generate LLVM, don't check *)
            ("-c", Compile) ] (* Generate, check LLVM IR *)
  else Compile in
  let (ic, oc, _) = 
    let infile = Sys.argv.(2) in
    let i = String.rindex infile '.' in
    let executable = String.sub infile 0 i in
    let outfile = executable ^ ".ll" in
    (open_in infile, open_out outfile, executable)
  in
  let lexbuf = Lexing.from_channel ic in
  let ast = Parser.program Scanner.token lexbuf in
  Semant.check ast; 
  match action with
    Ast -> print_string (Ast.string_of_program ast)
  | LLVM_IR -> print_string (Llvm.string_of_llmodule (Codegen.translate ast))
  | Compile -> let m = Codegen.translate ast in
    Llvm_analysis.assert_valid_module m;
    fprintf oc "%s" (Llvm.string_of_llmodule m);
    close_out oc
