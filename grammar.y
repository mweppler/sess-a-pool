class SessPoolParser

token CLASS
token CONSTANT
token DEF
token ELSE
token ELSIF
token END
token FALSE
token FLOAT
token FUNCTION
token IDENTIFIER
token IF
token INDENT
token INTEGER
token NEWLINE
token NIL
token OUTDENT
token OPERATOR
token RETURN
token STRING
token SYMBOL
token TRUE
token VALUE
token WHILE

prechigh
  left  '.'
  right '!'
  left  '*' '/'
  left  '+' '-'
  left  '>' '>=' '<' '<='
  left  '==' '!='
  left  '&&'
  left  '||'
  right '='
  left  ','
preclow

rule
  Root:
    /* nothing */                      { result = Nodes.new([]) }
  | Expressions                        { result = val[0] }
  ;

  # Any list of expressions, class or method body, separated by line breaks.
  Expressions:
    Expression                         { result = Nodes.new(val) }
  | Expressions Terminator Expression  { result = val[0] << val[2] }
    # To ignore trailing line breaks
  | Expressions Terminator             { result = val[0] }
  | Terminator                         { result = Nodes.new([]) }
  ;

  # All types of expressions in our language
  Expression:
    Literal
  | Call
  | Operator
  | Constant
  | Assign
  | Def
  | Class
  | If
  | '(' Expression ')'    { result = val[1] }
  ;

  # All tokens that can terminate an expression
  Terminator:
    NEWLINE
  | ";"
  ;

  # All hard-coded values
  Literal:
    FLOAT                         { result = NumberNode.new(val[0]) }
  | INTEGER                       { result = NumberNode.new(val[0]) }
  | STRING                        { result = StringNode.new(val[0]) }
  | TRUE                          { result = TrueNode.new }
  | FALSE                         { result = FalseNode.new }
  | NIL                           { result = NilNode.new }
  ;

  # A method call
  Call:
    # method
    IDENTIFIER                    { result = CallNode.new(nil, val[0], []) }
    # method(arguments)
  | IDENTIFIER "(" ArgList ")"    { result = CallNode.new(nil, val[0], val[2]) }
    # receiver.method
  | Expression "." IDENTIFIER     { result = CallNode.new(val[0], val[2], []) }
    # receiver.method(arguments)
  | Expression "."
      IDENTIFIER "(" ArgList ")"  { result = CallNode.new(val[0], val[2], val[4]) }
  ;

  ArgList:
    /* nothing */                 { result = [] }
  | Expression                    { result = val }
  | ArgList "," Expression        { result = val[0] << val[2] }
  ;

  Operator:
  # Binary operators
    Expression '||' Expression    { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '&&' Expression    { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '==' Expression    { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '!=' Expression    { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>' Expression     { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>=' Expression    { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<' Expression     { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<=' Expression    { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '+' Expression     { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '-' Expression     { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '*' Expression     { result = CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '/' Expression     { result = CallNode.new(val[0], val[1], [val[2]]) }
  ;

  Constant:
    CONSTANT                      { result = GetConstantNode.new(val[0]) }
  ;

  # Assignment to a variable or constant
  Assign:
    IDENTIFIER "=" Expression     { result = SetLocalNode.new(val[0], val[2]) }
  | CONSTANT "=" Expression       { result = SetConstantNode.new(val[0], val[2]) }
  ;

  # Method definition
  Def:
    DEF IDENTIFIER Block          { result = DefNode.new(val[1], [], val[2]) }
  | DEF IDENTIFIER
      "(" ParamList ")" Block     { result = DefNode.new(val[1], val[3], val[5]) }
  ;

  ParamList:
    /* nothing */                 { result = [] }
  | IDENTIFIER                    { result = val }
  | ParamList "," IDENTIFIER      { result = val[0] << val[2] }
  ;

  # Class definition
  Class:
    CLASS CONSTANT Block          { result = ClassNode.new(val[1], val[2]) }
  ;

  # if block
  If:
    IF Expression Block           { result = IfNode.new(val[1], val[2]) }
  ;

  Block:
    INDENT Expressions OUTDENT    { result = val[1] }
  ;
end

---- header
  require 'sess_pool_scanner'
  require 'nodes'

---- inner
  def parse(code, show_tokens=false)
    @tokens = SessPoolScanner.new.tokenize(code)
    puts @tokens.inspect if show_tokens
    do_parse
  end

  def next_token
    @tokens.shift
  end
