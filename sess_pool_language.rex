class SessPoolScanner
rule
  \s+                  # no action
  \bif\b               { [:IF, text] }
  >                    { [:GREATER_THAN, text] }
  \d+                  { [:INTEGER, text.to_i] }
  [a-z_][a-zA-Z_]+     { [:IDENTIFIER, text] }
  [A-Z_]+              { [:CONSTANT, text] }
  \:[a-zA-Z]+          { [:SYMBOL, text] }
  "\b[\\"]*.*?\b"      { [:STRING, text] }
  '\b[\\"]*.*?\b'      { [:STRING_LITERAL, text] }
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
