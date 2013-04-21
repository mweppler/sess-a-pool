require 'spec_helper'

describe SessPoolScanner do
  let(:scanner) { SessPoolScanner.new }

  it 'tokenizes the beginning, text and end of a comment' do
    tokens = [[:COMMENT_BEGIN, "/*"], [:COMMENT, " This is a comment "], [:COMMENT_END, "*/"]]
    expect(scanner.tokenize("/* This is a comment */")).to eq(tokens)
  end

  it 'tokenizes the following keywords (if, else, true, false, nil)' do
    tokens = [[:IF, "if"], [:ELSE, "else"], [:TRUE, "true"], [:FALSE, "false"], [:NIL, "nil"]]
    expect(scanner.tokenize("if else true false nil")).to eq(tokens)
  end

  it 'tokenizes an identifier' do
    expect(scanner.tokenize("print")).to eq([[:IDENTIFIER, "print"]])
  end

  it 'tokenizes an identifier even if a keyword (if) is within the text of the identifier' do
    expect(scanner.tokenize("identifier")).to eq([[:IDENTIFIER, "identifier"]])
  end

  it 'tokenizes a constant' do
    expect(scanner.tokenize("MY_CONSTANT")).to eq([[:CONSTANT, "MY_CONSTANT"]])
  end

  it 'tokenizes a float' do
    expect(scanner.tokenize("30.00")).to eq([[:FLOAT, 30.0]])
  end

  it 'tokenizes a negative float' do
    expect(scanner.tokenize("-25.0")).to eq([[:FLOAT, -25.0]])
  end

  it 'tokenizes an integer' do
    expect(scanner.tokenize("3000")).to eq([[:INTEGER, 3000]])
  end

  it 'tokenizes a negative integer' do
    expect(scanner.tokenize("-5")).to eq([[:INTEGER, -5]])
  end

  it 'tokenizes a symbol' do
    expect(scanner.tokenize(":PAGE")).to eq([[:SYMBOL, ":PAGE"]])
  end

  it 'tokenizes a string' do
    expect(scanner.tokenize(%{"hello"})).to eq([[:STRING, "hello"]])
  end

  it 'tokenizes a number and a string' do
    tokens = [[:STRING, "hello"], [:INTEGER, 3000]]
    expect(scanner.tokenize(%{"hello" 3000})).to eq(tokens)
  end

  it 'tokenizes a simple if/else block' do
    code = <<CODE
if test == "test":
  print "true"
else:
  print "false"
CODE
    tokens = [[:IF, "if"], [:IDENTIFIER, "test"], [:OPERATOR, "=="], [:STRING, "test"], [":", ":"],
      [:INDENT, 2], [:IDENTIFIER, "print"], [:STRING, "true"], [:NEWLINE, "\n"],
      [:OUTDENT, 0], [:ELSE, "else"], [":", ":"],
      [:INDENT, 2], [:IDENTIFIER, "print"], [:STRING, "false"]
    ]
    expect(scanner.tokenize(code)).to eq(tokens)
  end

  it 'tokenizes a calculation' do
    tokens = [[:INTEGER, 5], [:OPERATOR, "+"], [:INTEGER, 20]]
    expect(scanner.tokenize("5 + 20")).to eq(tokens)
 end

  it 'tokenizes an identifier and ignores the newline' do
    code = <<CODE
print

CODE
    expect(scanner.tokenize(code)).to eq([[:IDENTIFIER, "print"]])
  end

  it 'tokenizes a simple function block' do
    code = <<CODE
function my_function:
  if true
    print "true"
CODE
    tokens = [[:FUNCTION, "function"], [:IDENTIFIER, "my_function"], [":", ":"],
      [:INDENT, 2], [:IF, "if"], [:TRUE, "true"],
      [:INDENT, 4], [:IDENTIFIER, "print"], [:STRING, "true"]
    ]
    expect(scanner.tokenize(code)).to eq(tokens)
  end

  it 'tokenizes a slightly more difficult indentation case' do
    code = <<-CODE
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
      [:IF, "if"], [:INTEGER, 1], [":", ":"],
      [:INDENT, 2], [:IF, "if"], [:INTEGER, 2], [":", ":"],
      [:INDENT, 4], [:IDENTIFIER, "print"], [:STRING, "..."], [:NEWLINE, "\n"],
      [:IF, "if"], [:FALSE, "false"], [":", ":"],
      [:INDENT, 6], [:IDENTIFIER, "pass"], [:NEWLINE, "\n"],
      [:OUTDENT, 4], [:IDENTIFIER, "print"], [:STRING, "done!"], [:NEWLINE, "\n"],
      [:OUTDENT, 2], [:INTEGER, 2], [:NEWLINE, "\n"],
      [:OUTDENT, 0], [:IDENTIFIER, "print"], [:STRING, "The End"]
    ]
    expect(scanner.tokenize(code)).to eq(tokens)
  end
end
