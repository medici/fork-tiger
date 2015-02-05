(*s: main.ml *)
module S = Symbol
module F = Frame
module V = Environment
module M = Semantics
(*s: standard basis *)
let base_tenv =
(* name     type *)
[ "int",    M.INT
; "string", M.STRING
]
(*x: standard basis *)
let base_venv = 
(* name        cc        args                    return *)
[ "print",     Some "C", [M.STRING],             M.UNIT
; "printi",    Some "C", [M.INT],                M.UNIT
; "flush",     Some "C", [],                     M.UNIT
; "getchar",   None,     [],                     M.STRING
; "ord",       Some "C", [M.STRING],             M.INT
; "chr",       None,     [M.INT],                M.STRING
; "size",      Some "C", [M.STRING],             M.INT
; "sizea",     Some "C", [M.ARRAY M.ANY],        M.INT
; "substring", None,     [M.STRING;M.INT;M.INT], M.STRING
; "concat",    None,     [M.STRING;M.STRING],    M.STRING
; "not",       Some "C", [M.INT],                M.INT
; "exit",      Some "C", [M.INT],                M.UNIT
]
(*x: standard basis *)
let imports =
  let internal = [ "alloc"
                 ; "call_gc"
                 ; "compare_str"
                 ; "bounds_check"
                 ; "set_handler"
                 ; "raise"
                 ; "unwind"
                 ; "spawn"
                 ]
  in
  List.map (fun(n,_,_,_) -> n) base_venv @ internal
(*e: standard basis *)
(*s: compiler driver *)
let emit_function (frm,ex) =
  if Option.print_ext()  then Tree.print_exp ex;
  let ltree = Canonical.linearize (Tree.EXP ex) in
  if Option.print_lext() then List.iter Tree.print_stm ltree;
  List.iter (fun (x,p) -> ignore(Frame.alloc_temp frm x p))
            (Tree.find_temps ltree);
  Frame.output_header frm;
  Codegen.emit ltree;
  Frame.output_footer frm

(*s: function Main.compile *)
let compile ch =
  let base_env = V.new_env base_tenv base_venv in

  let lexbuf = Lexing.from_channel ch in
  let ast = Parser.program Lexer.token lexbuf in
  (*s: [[Main.compile()]] if dump AST option *)
  if Option.print_ast() then Ast.print_tree ast;
  (*e: [[Main.compile()]] if dump AST option *)

  let exl = Semantics.translate base_env ast in
  Codegen.output_file_header imports;
  Frame.output_strings();
  List.iter emit_function exl
(*e: function Main.compile *)

let _ =
  try
    Option.parse_cmdline();
    compile (Option.channel())
  with Error.Error ex ->
    Error.handle_exception ex
(*e: compiler driver *)
(*e: main.ml *)
