class SessPoolScanner
macro
  BLANK       \s+
  CONSTANT    [A-Z_]+
  FLOAT       [\+|-]?\d+\.\d*
  KEYWORD     if|else|elsif|true|false|nil|def|end|function|while|return
  IDENTIFIER  [a-z_][a-zA-Z_]+
  INTEGER     [\+|-]?\d+
  NEWLINE     \n
  OPERATOR    \|\||&&|==|!=|<=|>=|<|>|\+|\-|\*|\/
  STRING      "\b[\\"]*.*?\b"
  SYMBOL      \:[A-Z_]+
  VALUE       .+
  WHITESPACE  \ +
rule
  {KEYWORD}              { [text.upcase.to_sym, text] }
  {IDENTIFIER}           { [:IDENTIFIER, text] }
  {CONSTANT}             { [:CONSTANT, text] }
  {SYMBOL}               { [:SYMBOL, text] }
  {FLOAT}                { [:FLOAT, text.to_f] }
  {INTEGER}              { [:INTEGER, text.to_i] }
  {STRING}               { [:STRING, text] }
  {OPERATOR}             { [:OPERATOR, text] }
  {NEWLINE}{WHITESPACE}  { [:INDENT, text.size - 1] }
  {NEWLINE}{NEWLINE}     # NO ACTION
  {BLANK}                # NO ACTION
  {VALUE}                { [:VALUE, text] }
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
