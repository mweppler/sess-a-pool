class SessPoolScanner
macro
  BLANK            \s+
  CHARACTER        .+
  COMMENT_BEGIN    \/\*
  COMMENT_END      \*\/
  CONSTANT         [A-Z_]{1}[a-zA-Z0-9_]*
  FLOAT            [\+|-]?\d+\.\d+
  KEYWORD          class|def|else|elsif|end|false|function|if|nil|return|true|while
  IDENTIFIER       [a-z_]{1}[a-zA-Z_]*
  INTEGER          [\+|-]?\d+
  NEWLINE          \n
  NON_WHITESPACE   \S+
  OPERATOR         \|\||&&|==|!=|<=|>=|<|>|\*|\/|\+|\-
  SPECIAL          =|,|!|;|:|_|&|@|%|~|`|\||\(|\)|\[|\]|\{|\}|\\|\^|\$|\?|\.|\#
  STRING           "[\\"]*.*?"
  SYMBOL           \:[A-Z_]+
  WHITESPACE       \ +
rule
         {COMMENT_BEGIN}                 { @state = :COMM ; [:COMMENT_BEGIN, text] }
  :COMM  {COMMENT_END}                   { @state = nil ; [:COMMENT_END, text] }
  :COMM  ({CHARACTER})(?={COMMENT_END})  { [:COMMENT, text] }
         {KEYWORD}                       { [text.upcase.to_sym, text] }
         {IDENTIFIER}                    { [:IDENTIFIER, text] }
         {CONSTANT}                      { [:CONSTANT, text] }
         {SYMBOL}                        { [:SYMBOL, text] }
         {FLOAT}                         { [:FLOAT, text.to_f] }
         {INTEGER}                       { [:INTEGER, text.to_i] }
         {STRING}                        { [:STRING, text[1...-1]] }
         {NEWLINE}{WHITESPACE}           {
                                           @current_indent ||= 0
                                           @stack          ||= []
                                           indent_size       = text.size - 1 # the - 1 is for the new line
                                           token           ||= []
                                           if indent_size > @current_indent
                                             @stack.push indent_size
                                             @current_indent = @stack.last
                                             tokens = [:INDENT, @current_indent]
                                           elsif indent_size < @current_indent
                                             @stack.pop
                                             @current_indent = @stack.last || 0
                                             tokens = [:OUTDENT, @current_indent, :NEWLINE, "\n"] # an outdent gets a new line to terminate the block
                                           elsif indent_size == @current_indent
                                             # stack is unchanged
                                             tokens = [:NEWLINE, "\n"]
                                           end
                                           tokens
                                         }
         {NEWLINE}(?={NON_WHITESPACE})   {
                                           tokens ||= []
                                           if @stack.nil?
                                             # not so sure about this one
                                             tokens = [:NEWLINE, "\n"]
                                           else
                                             unless @stack.empty?
                                               while !@stack.empty?
                                                 @stack.pop # get rid of one
                                                 @current_indent = @stack.last || 0
                                                 tokens = tokens + [:OUTDENT, @current_indent, :NEWLINE, "\n"] # an outdent gets a new line to terminate the block
                                               end
                                             end
                                           end
                                           tokens
                                         }
         {OPERATOR}                      { [text, text] }
         {NEWLINE}                       # NO ACTION
         {BLANK}                         # NO ACTION
         {SPECIAL}                       { [text, text] }
inner
  def tokenize(code, show_tokens=false)
    scan_setup(code)
    tokens = []
    while token = next_token
      if token.size > 2
        tokens = tokens + split_tokens_greater_than_two(token)
      else
        tokens << token
      end
    end

    tokens = tokens + empty_the_stack unless(@stack.nil?)

    puts tokens if show_tokens
    tokens
  end

  private

  def empty_the_stack
    tokens = []
    while !@stack.empty?
      @stack.pop
      tokens << [:OUTDENT, @stack.last || 0]
    end
    tokens
  end

  def split_tokens_greater_than_two(token)
    tokens = []
    tokens << [token.shift, token.shift]  while token.size > 0
    tokens
  end
end
