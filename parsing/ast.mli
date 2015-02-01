(*s: parsing/ast.mli *)
(*s: ast.mli *)
(*s: types(ast.nw) *)
type pos    = int 
and  symbol = Symbol.symbol
(*x: types(ast.nw) *)
type dec =
    FunctionDec  of (symbol * field list * symbol option * exp * pos) list
  | VarDec       of symbol * symbol option * exp * pos
  | TypeDec      of (symbol * ty * pos) list
  | ExceptionDec of symbol * pos
(*x: types(ast.nw) *)
and ty =
    NameTy   of symbol * pos
  | RecordTy of field list
  | ArrayTy  of symbol * pos
(*x: types(ast.nw) *)
and field = (symbol * symbol * pos)
(*x: types(ast.nw) *)
and var =
    SimpleVar    of symbol * pos
  | FieldVar     of var * symbol * pos
  | SubscriptVar of var * exp * pos
(*x: types(ast.nw) *)
and exp =
    NilExp
  | VarExp    of var
  | IntExp    of int
  | StringExp of string * pos
  | RecordExp of symbol * (symbol * exp * pos) list * pos
  | ArrayExp  of symbol * exp * exp * pos
  | AssignExp of var * exp * pos
  | OpExp     of exp * oper * exp * pos
  | CallExp   of symbol * exp list * pos
  | IfExp     of exp * exp * exp option * pos
  | WhileExp  of exp * exp * pos
  | ForExp    of symbol * exp * exp * exp * pos
  | BreakExp  of pos
  | SeqExp    of exp list * pos
  | LetExp    of dec list * exp * pos
  | TryExp    of exp * (symbol * exp * pos) list * pos
  | RaiseExp  of symbol * pos
  | SpawnExp  of symbol * pos
(*x: types(ast.nw) *)
and oper = PlusOp | MinusOp | TimesOp | DivideOp
         | EqOp | NeqOp | LtOp | LeOp | GtOp | GeOp
(*e: types(ast.nw) *)
val print_tree : exp -> unit
(*e: ast.mli *)
(*e: parsing/ast.mli *)
