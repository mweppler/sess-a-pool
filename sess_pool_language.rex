class SessPoolScanner
macro
  BLANK       \s+
  CONSTANT    [A-Z_]+
  FLOAT       \d+\.\d*
  KEYWORD     if|else|true|false|nil
  IDENTIFIER  [a-z_][a-zA-Z_]+
  INDENT      \n\s+
  INTEGER     \d+
  OPERATOR    \|\||&&|==|!=|<=|>=|<|>|\+|\-|\*|\/
  STRING      "\b[\\"]*.*?\b"
  SYMBOL      \:[A-Z_]+
  VALUE       .+
rule
  {KEYWORD}     { [text.upcase.to_sym, text] }
  {IDENTIFIER}  { [:IDENTIFIER, text] }
  {CONSTANT}    { [:CONSTANT, text] }
  {SYMBOL}      { [:SYMBOL, text] }
  {FLOAT}       { [:FLOAT, text.to_f] }
  {INTEGER}     { [:INTEGER, text.to_i] }
  {STRING}      { [:STRING, text] }
  {OPERATOR}    { [:OPERATOR, text] }
  {INDENT}      { [:INDENT, text.size - 1] }
  {BLANK}       # NO ACTION
  {VALUE}       { [:VALUE, text] }
inner
  def tokenize(code)
    scan_setup(code)
    tokens = []
    while token = next_token
      tokens << token
    end
    tokens
  end
end
