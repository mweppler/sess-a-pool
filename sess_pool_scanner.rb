#--
# DO NOT MODIFY!!!!
# This file is automatically generated by rex 1.0.5
# from lexical definition file "sess_pool_language.rex".
#++

require 'racc/parser'
class SessPoolScanner < Racc::Parser
  require 'strscan'

  class ScanError < StandardError ; end

  attr_reader   :lineno
  attr_reader   :filename
  attr_accessor :state

  def scan_setup(str)
    @ss = StringScanner.new(str)
    @lineno =  1
    @state  = nil
  end

  def action
    yield
  end

  def scan_str(str)
    scan_setup(str)
    do_parse
  end
  alias :scan :scan_str

  def load_file( filename )
    @filename = filename
    open(filename, "r") do |f|
      scan_setup(f.read)
    end
  end

  def scan_file( filename )
    load_file(filename)
    do_parse
  end


  def next_token
    return if @ss.eos?
    
    # skips empty actions
    until token = _next_token or @ss.eos?; end
    token
  end

  def _next_token
    text = @ss.peek(1)
    @lineno  +=  1  if text == "\n"
    token = case @state
    when nil
      case
      when (text = @ss.scan(/\/\*/))
         action { @state = :COMM ; [:COMMENT_BEGIN, text] }

      when (text = @ss.scan(/class|def|else|elsif|end|false|function|if|nil|return|true|while/))
         action { [text.upcase.to_sym, text] }

      when (text = @ss.scan(/[a-z_]{1}[a-zA-Z_]*/))
         action { [:IDENTIFIER, text] }

      when (text = @ss.scan(/[A-Z_]{1}[a-zA-Z0-9_]*/))
         action { [:CONSTANT, text] }

      when (text = @ss.scan(/\:[A-Z_]+/))
         action { [:SYMBOL, text] }

      when (text = @ss.scan(/[\+|-]?\d+\.\d+/))
         action { [:FLOAT, text.to_f] }

      when (text = @ss.scan(/[\+|-]?\d+/))
         action { [:INTEGER, text.to_i] }

      when (text = @ss.scan(/"[\\"]*.*?"/))
         action { [:STRING, text[1...-1]] }

      when (text = @ss.scan(/\n +/))
         action {
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
                                             tokens = [:NEWLINE, "\n"]
                                           end
                                           tokens
                                         }


      when (text = @ss.scan(/\n(?=\S+)/))
         action {
                                           tokens ||= []
                                           if @stack.nil?
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


      when (text = @ss.scan(/\|\||&&|==|!=|<=|>=|<|>|\*|\/|\+|\-/))
         action { [text, text] }

      when (text = @ss.scan(/\n/))
        ;

      when (text = @ss.scan(/\s+/))
        ;

      when (text = @ss.scan(/=|,|!|;|:|_|&|@|%|~|`|\||\(|\)|\[|\]|\{|\}|\\|\^|\$|\?|\.|\#/))
         action { [text, text] }

      else
        text = @ss.string[@ss.pos .. -1]
        raise  ScanError, "can not match: '" + text + "'"
      end  # if

    when :COMM
      case
      when (text = @ss.scan(/\*\//))
         action { @state = nil ; [:COMMENT_END, text] }

      when (text = @ss.scan(/(.+)(?=\*\/)/))
         action { [:COMMENT, text] }

      else
        text = @ss.string[@ss.pos .. -1]
        raise  ScanError, "can not match: '" + text + "'"
      end  # if

    else
      raise  ScanError, "undefined state: '" + state.to_s + "'"
    end  # case state
    token
  end  # def _next_token

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
end # class
