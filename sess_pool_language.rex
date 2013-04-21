class SessPoolScanner
macro
  BLANK            \s+
  COMMENT_BEGIN    \/\*
  COMMENT_END      \*\/
  CONSTANT         [A-Z_]+
  FLOAT            [\+|-]?\d+\.\d+
  KEYWORD          if|else|elsif|true|false|nil|def|end|function|while|return
  IDENTIFIER       [a-z_][a-zA-Z_]+
  INTEGER          [\+|-]?\d+
  NEWLINE          \n
  NON_WHITESPACE   \S+
  DOUBLE_OPERATOR  \|\||&&|==|!=|<=|>=|<|>|\+|\-|\*|\/
  SINGLE_OPERATOR  \(|\)|,|\.|!|;|\[|\]|\{|\}|:|\?|_|&|\^|%|\$|#|@|~|`
  #STRING           "[\\"]*.*?"
  STRING           "(.*?)"
  SYMBOL           \:[A-Z_]+
  VALUE            .+
  WHITESPACE       \ +
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
         {STRING}                       { [:STRING, text[1...-1]] }
         {NEWLINE}{WHITESPACE}          {
                                          @current_indent ||= 0
                                          indent_size = text.size - 1
                                          if indent_size > @current_indent
                                            @current_indent = indent_size
                                            [:INDENT, @current_indent]
                                          elsif indent_size < @current_indent
                                            @current_indent = indent_size
                                            [:NEWLINE, "\n", :OUTDENT, @current_indent]
                                          elsif indent_size == @current_indent
                                            # NO ACTION
                                            [:NEWLINE, "\n"]
                                          end
                                        }
         {NEWLINE}(?={NON_WHITESPACE})  {
                                          if @current_indent.nil?
                                            [:NEWLINE, "\n"]
                                          else
                                            if @current_indent >= 0
                                              @current_indent = 0
                                              [:NEWLINE, "\n", :OUTDENT, @current_indent]
                                            end
                                          end
                                        }
         {NEWLINE}                      # NO ACTION
         {BLANK}                        # NO ACTION
         {DOUBLE_OPERATOR}              { [:OPERATOR, text] }
         {SINGLE_OPERATOR}              { [text, text] }
         {VALUE}                        { [:VALUE, text] }
inner
  def tokenize(code, show_tokens=false)
    scan_setup(code)
    tokens = []
    while token = next_token
      if token.size > 2
        while token.size > 0
          tokens << [token.shift, token.shift]
        end
      else
        tokens << token
      end
    end
    puts tokens if show_tokens
    tokens
  end
end
