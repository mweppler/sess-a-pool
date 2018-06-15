require 'spec_helper'

describe SessPoolScanner do
  let(:scanner) { SessPoolScanner.new }

  it 'tokenizes the beginning, text and end of a comment' do
    code = <<~CODE
      /* This is a comment */
    CODE
    tokens = [
      [:COMMENT_BEGIN, '/*'], [:COMMENT, ' This is a comment '], [:COMMENT_END, '*/']
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes the following keywords (if, else, true, false, nil)' do
    code = <<~CODE
      if else true false nil
    CODE
    tokens = [
      [:IF, 'if'], [:ELSE, 'else'], [:TRUE, 'true'], [:FALSE, 'false'], [:NIL, 'nil']
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes an identifier' do
    code = <<~CODE
      print
    CODE
    tokens = [
      [:IDENTIFIER, 'print']
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes an identifier even if a keyword (if) is within the text of the identifier' do
    code = <<~CODE
      identifier
    CODE
    tokens = [
      [:IDENTIFIER, 'identifier']
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes a constant' do
    code = <<~CODE
      MY_CONSTANT
    CODE
    tokens = [
      [:CONSTANT, 'MY_CONSTANT']
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes a float' do
    code = <<~CODE
      30.00
    CODE
    tokens = [
      [:FLOAT, 30.0]
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes a negative float' do
    code = <<~CODE
      -25.0
    CODE
    tokens = [
      [:FLOAT, -25.0]
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes an integer' do
    code = <<~CODE
      3000
    CODE
    tokens = [
      [:INTEGER, 3000]
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes a negative integer' do
    code = <<~CODE
      -5
    CODE
    tokens = [
      [:INTEGER, -5]
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes a symbol' do
    code = <<~CODE
      :PAGE
    CODE
    tokens = [
      [:SYMBOL, ":PAGE"]
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes a double quoted string' do
    code = <<~CODE
      "hello"
    CODE
    tokens = [
      [:STRING, 'hello']
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes a string and a number' do
    code = <<~CODE
      "hello" 3000
    CODE
    tokens = [
      [:STRING, "hello"], [:INTEGER, 3000]
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes a simple if/else block' do
    code = <<~CODE
      if test == "test":
        print "true"
      else:
        print "false"
    CODE
    tokens = [
      [:IF, 'if'], [:IDENTIFIER, 'test'], ['==', '=='], [:STRING, 'test'], [':', ':'],
      [:INDENT, 2], [:IDENTIFIER, 'print'], [:STRING, 'true'],
      [:OUTDENT, 0], [:NEWLINE, "\n"],
      [:ELSE, 'else'], [':', ':'],
      [:INDENT, 2], [:IDENTIFIER, 'print'], [:STRING, 'false'],
      [:OUTDENT, 0]
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes a calculation' do
    code = <<~CODE
      5 + 20
    CODE
    tokens = [
      [:INTEGER, 5], ["+", "+"], [:INTEGER, 20]
    ]
    expect(scanner.tokenize(code)).to eq tokens
 end

  it 'tokenizes an identifier and ignores the newline' do
    code = <<~CODE
      print

    CODE
    tokens = [
      [:IDENTIFIER, 'print']
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes a simple while block' do
    code = <<~CODE
      while true:
        print "true"
    CODE
    tokens = [
      [:WHILE, 'while'], [:TRUE, 'true'], [':', ':'],
      [:INDENT, 2], [:IDENTIFIER, 'print'], [:STRING, 'true'],
      [:OUTDENT, 0]
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes a simple function block' do
    code = <<~CODE
      function my_function:
        if true
          print "true"
    CODE
    tokens = [
      [:FUNCTION, 'function'], [:IDENTIFIER, 'my_function'], [':', ':'],
      [:INDENT, 2], [:IF, 'if'], [:TRUE, 'true'],
      [:INDENT, 4], [:IDENTIFIER, 'print'], [:STRING, 'true'],
      [:OUTDENT, 2], [:OUTDENT, 0]
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes a slightly more difficult indentation case' do
    code = <<~CODE
      if 1:
        if 2:
          print "..."
          if false:
            pass
          print "done!"
        2

      print "The End"
    CODE
    tokens = [
      [:IF, 'if'], [:INTEGER, 1], [':', ':'],
      [:INDENT, 2], [:IF, 'if'], [:INTEGER, 2], [':', ':'],
      [:INDENT, 4], [:IDENTIFIER, 'print'], [:STRING, '...'], [:NEWLINE, "\n"],
      [:IF, 'if'], [:FALSE, 'false'], [':', ':'],
      [:INDENT, 6], [:IDENTIFIER, 'pass'],
      [:OUTDENT, 4], [:NEWLINE, "\n"], [:IDENTIFIER, 'print'], [:STRING, 'done!'],
      [:OUTDENT, 2], [:NEWLINE, "\n"], [:INTEGER, 2],
      [:OUTDENT, 0], [:NEWLINE, "\n"], [:IDENTIFIER, 'print'], [:STRING, 'The End']
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end

  it 'tokenizes an assignment' do
    code = <<~CODE
      a = 1
    CODE
    tokens = [
      [:IDENTIFIER, 'a'], ['=', '='], [:INTEGER, 1]
    ]
    expect(scanner.tokenize(code)).to eq tokens
  end
end

