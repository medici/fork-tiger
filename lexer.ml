# 1 "lexer.mll"
 
module E = Error
module P = Parser

(* The table of keywords *)
let keyword_table = Hashtbl.create 22;;
List.iter (fun (key, data) -> Hashtbl.add keyword_table key data)
  [
   "and",       P.AND;
   "array",     P.ARRAY;
   "break",     P.BREAK;
   "do",        P.DO;
   "else",      P.ELSE;
   "end",       P.END;
   "exception", P.EXCEPTION;
   "for",       P.FOR;
   "function",  P.FUNCTION;
   "handle",    P.HANDLE;
   "if",        P.IF;
   "in",        P.IN;
   "let",       P.LET;
   "nil",       P.NIL;
   "of",        P.OF;
   "or",        P.OR;
   "raise",     P.RAISE;
   "spawn",     P.SPAWN;
   "then",      P.THEN;
   "to",        P.TO;
   "try",       P.TRY;
   "type",      P.TYPE;
   "var",       P.VAR;
   "while",     P.WHILE;
 ];;
  
(* To buffer string literals *)

let escape c = 
  match c with
  | 'n' -> '\n'
  | 'r' -> '\r'
  | 'b' -> '\b'
  | 't' -> '\t'
  | _ -> c

let line_num = ref 0
let string_start_pos = ref 0
let buffer = Buffer.create 30
let comment_pos = Stack.create()

# 52 "lexer.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base = 
   "\000\000\225\255\226\255\227\255\228\255\229\255\230\255\231\255\
    \232\255\233\255\235\255\237\255\002\000\239\255\240\255\031\000\
    \243\255\244\255\246\255\033\000\249\255\053\000\251\255\078\000\
    \088\000\005\000\255\255\250\255\248\255\242\255\234\255\238\255\
    \137\000\252\255\253\255\049\000\104\000\254\255\146\000\147\000\
    \177\000";
  Lexing.lex_backtrk = 
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\019\000\255\255\255\255\014\000\
    \255\255\255\255\255\255\008\000\255\255\010\000\255\255\003\000\
    \002\000\001\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\004\000\004\000\255\255\255\255\002\000\
    \255\255";
  Lexing.lex_default = 
   "\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\255\255\000\000\000\000\255\255\
    \000\000\000\000\000\000\255\255\000\000\255\255\000\000\255\255\
    \255\255\255\255\000\000\000\000\000\000\000\000\000\000\000\000\
    \022\000\000\000\000\000\255\255\255\255\000\000\039\000\039\000\
    \255\255";
  Lexing.lex_trans = 
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\025\000\026\000\000\000\025\000\026\000\025\000\000\000\
    \000\000\025\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \025\000\000\000\022\000\000\000\000\000\025\000\020\000\000\000\
    \011\000\005\000\003\000\008\000\018\000\010\000\017\000\021\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\019\000\004\000\012\000\016\000\015\000\031\000\
    \030\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\013\000\029\000\006\000\028\000\027\000\
    \037\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\014\000\009\000\007\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\026\000\034\000\000\000\000\000\034\000\000\000\
    \000\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\035\000\026\000\255\255\000\000\024\000\
    \036\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\037\000\000\000\000\000\000\000\000\000\
    \037\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\040\000\255\255\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \002\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\037\000\000\000\000\000\
    \000\000\000\000\000\000\037\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\037\000\
    \000\000\000\000\000\000\037\000\000\000\037\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\033\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\033\000\255\255\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000";
  Lexing.lex_check = 
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\255\255\000\000\000\000\025\000\255\255\
    \255\255\025\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\255\255\000\000\255\255\255\255\025\000\000\000\255\255\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\012\000\
    \012\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\015\000\000\000\019\000\021\000\
    \035\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\036\000\032\000\255\255\255\255\032\000\255\255\
    \255\255\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\032\000\038\000\039\000\255\255\024\000\
    \032\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\040\000\255\255\255\255\255\255\255\255\
    \040\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\038\000\039\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\040\000\255\255\255\255\
    \255\255\255\255\255\255\040\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\040\000\
    \255\255\255\255\255\255\040\000\255\255\040\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\032\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\038\000\039\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255";
  Lexing.lex_base_code = 
   "";
  Lexing.lex_backtrk_code = 
   "";
  Lexing.lex_default_code = 
   "";
  Lexing.lex_trans_code = 
   "";
  Lexing.lex_check_code = 
   "";
  Lexing.lex_code = 
   "";
}

let rec token lexbuf =
    __ocaml_lex_token_rec lexbuf 0
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 58 "lexer.mll"
         ( incr line_num;
           E.add_source_mapping (Lexing.lexeme_end lexbuf) !line_num;
           token lexbuf )
# 210 "lexer.ml"

  | 1 ->
# 61 "lexer.mll"
            ( token lexbuf )
# 215 "lexer.ml"

  | 2 ->
# 63 "lexer.mll"
      ( let s = Lexing.lexeme lexbuf in
        try
          Hashtbl.find keyword_table s
        with Not_found ->
          P.ID s )
# 224 "lexer.ml"

  | 3 ->
# 69 "lexer.mll"
      ( P.INT (int_of_string(Lexing.lexeme lexbuf)) )
# 229 "lexer.ml"

  | 4 ->
# 71 "lexer.mll"
      ( string_start_pos := Lexing.lexeme_start lexbuf;
        P.STRING (string lexbuf) )
# 235 "lexer.ml"

  | 5 ->
# 73 "lexer.mll"
         ( comment lexbuf; token lexbuf )
# 240 "lexer.ml"

  | 6 ->
# 74 "lexer.mll"
         ( P.AND )
# 245 "lexer.ml"

  | 7 ->
# 75 "lexer.mll"
         ( P.ASSIGN )
# 250 "lexer.ml"

  | 8 ->
# 76 "lexer.mll"
         ( P.COLON )
# 255 "lexer.ml"

  | 9 ->
# 77 "lexer.mll"
         ( P.COMMA )
# 260 "lexer.ml"

  | 10 ->
# 78 "lexer.mll"
         ( P.DIVIDE )
# 265 "lexer.ml"

  | 11 ->
# 79 "lexer.mll"
         ( P.DOT )
# 270 "lexer.ml"

  | 12 ->
# 80 "lexer.mll"
         ( P.EQ )
# 275 "lexer.ml"

  | 13 ->
# 81 "lexer.mll"
         ( P.GE )
# 280 "lexer.ml"

  | 14 ->
# 82 "lexer.mll"
         ( P.GT )
# 285 "lexer.ml"

  | 15 ->
# 83 "lexer.mll"
         ( P.LBRACE )
# 290 "lexer.ml"

  | 16 ->
# 84 "lexer.mll"
         ( P.LBRACK )
# 295 "lexer.ml"

  | 17 ->
# 85 "lexer.mll"
         ( P.LE )
# 300 "lexer.ml"

  | 18 ->
# 86 "lexer.mll"
         ( P.LPAREN )
# 305 "lexer.ml"

  | 19 ->
# 87 "lexer.mll"
         ( P.LT )
# 310 "lexer.ml"

  | 20 ->
# 88 "lexer.mll"
         ( P.MINUS )
# 315 "lexer.ml"

  | 21 ->
# 89 "lexer.mll"
         ( P.NEQ )
# 320 "lexer.ml"

  | 22 ->
# 90 "lexer.mll"
         ( P.OR )
# 325 "lexer.ml"

  | 23 ->
# 91 "lexer.mll"
         ( P.PLUS )
# 330 "lexer.ml"

  | 24 ->
# 92 "lexer.mll"
         ( P.RBRACE )
# 335 "lexer.ml"

  | 25 ->
# 93 "lexer.mll"
         ( P.RBRACK )
# 340 "lexer.ml"

  | 26 ->
# 94 "lexer.mll"
         ( P.RPAREN )
# 345 "lexer.ml"

  | 27 ->
# 95 "lexer.mll"
         ( P.SEMICOLON )
# 350 "lexer.ml"

  | 28 ->
# 96 "lexer.mll"
         ( P.TIMES )
# 355 "lexer.ml"

  | 29 ->
# 97 "lexer.mll"
         ( P.EOF )
# 360 "lexer.ml"

  | 30 ->
# 99 "lexer.mll"
      ( raise (E.Error(E.Illegal_character (Lexing.lexeme_char lexbuf 0),
                       Lexing.lexeme_start lexbuf)) )
# 366 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_token_rec lexbuf __ocaml_lex_state

and comment lexbuf =
    __ocaml_lex_comment_rec lexbuf 32
and __ocaml_lex_comment_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 103 "lexer.mll"
         ( Stack.push (Lexing.lexeme_start lexbuf) comment_pos;
           comment lexbuf; )
# 378 "lexer.ml"

  | 1 ->
# 105 "lexer.mll"
         ( try (ignore(Stack.pop comment_pos); comment lexbuf)
           with Stack.Empty -> () )
# 384 "lexer.ml"

  | 2 ->
# 107 "lexer.mll"
         ( incr line_num;
           E.add_source_mapping (Lexing.lexeme_end lexbuf) !line_num;
           comment lexbuf )
# 391 "lexer.ml"

  | 3 ->
# 110 "lexer.mll"
         ( let st = Stack.top comment_pos in
           raise (E.Error(E.Unterminated_comment, st)) )
# 397 "lexer.ml"

  | 4 ->
# 112 "lexer.mll"
         ( comment lexbuf )
# 402 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_comment_rec lexbuf __ocaml_lex_state

and string lexbuf =
    __ocaml_lex_string_rec lexbuf 38
and __ocaml_lex_string_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 116 "lexer.mll"
      ( let s = Buffer.contents buffer in
        (Buffer.clear buffer; s) )
# 414 "lexer.ml"

  | 1 ->
# 119 "lexer.mll"
      ( Buffer.add_char buffer (escape (Lexing.lexeme_char lexbuf 1));
        string lexbuf )
# 420 "lexer.ml"

  | 2 ->
# 122 "lexer.mll"
      ( Buffer.add_string buffer (Lexing.lexeme lexbuf);
        string lexbuf )
# 426 "lexer.ml"

  | 3 ->
# 125 "lexer.mll"
      ( raise (E.Error(E.Unterminated_string, !string_start_pos)) )
# 431 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_string_rec lexbuf __ocaml_lex_state

;;
