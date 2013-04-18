class SessPoolScanner
macro
  BLANK           \s+
  COMMENT_BEGIN   \/\*
  COMMENT_END     \*\/
  CONSTANT        [A-Z_]+
  FLOAT           [\+|-]?\d+\.\d*
  KEYWORD         if|else|elsif|true|false|nil|def|end|function|while|return
  IDENTIFIER      [a-z_][a-zA-Z_]+
  INTEGER         [\+|-]?\d+
  NEWLINE         \n
  NON_WHITESPACE  \S+
  OPERATOR        \|\||&&|==|!=|<=|>=|<|>|\+|\-|\*|\/
  STRING          "[\\"]*.*?"
  SYMBOL          \:[A-Z_]+
  VALUE           .+
  WHITESPACE      \ +
rule
         {COMMENT_BEGIN}                { @state = :COMM ; [:COMMENT_BEGIN, text] }
  :COMM  {COMMENT_END}                  { @state = nil ; [:COMMENT_END, text] }
  :COMM  ({VALUE})(?={COMMENT_END})     { [:COMMENT, text] }
         {KEYWORD}                      { [text.upcase.to_sym, text] }
         {IDENTIFIER}                   { [:IDENTIFIER, text] }
         {CONSTANT}                     { [:CONSTANT, text] }
         {SYMBOL}                       { [:SYMBOL, text] }
         {FLOAT}                        { [:FLOAT, text.to_f] }
         {INTEGER}                      { [:INTEGER, text.to_i] }
         {STRING}                       { [:STRING, text] }
         {OPERATOR}                     { [:OPERATOR, text] }
         {NEWLINE}{WHITESPACE}          {
                                          @current_indent ||= 0
                                          indent_size = text.size - 1
                                          if indent_size > @current_indent
                                            @current_indent = indent_size
                                            [:INDENT, @current_indent]
                                          elsif indent_size < @current_indent
                                            @current_indent = indent_size
                                            [:OUTDENT, @current_indent]
                                          elsif indent_size == @current_indent
                                            # NO ACTION
                                          end
                                        }
         {NEWLINE}(?={NON_WHITESPACE})  {
                                          if @current_indent >= 0
                                            @current_indent = 0
                                            [:OUTDENT, @current_indent]
                                          end
                                        }
         {NEWLINE}                      # NO ACTION
         {BLANK}                        # NO ACTION
         {VALUE}                        { [:VALUE, text] }
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
