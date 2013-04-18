require './sess_pool_scanner'

describe SessPoolScanner do
  let(:scanner) { SessPoolScanner.new }

  it 'tokenizes the beginning, text and end of a comment' do
    code = <<CODE
/* This is a comment */
CODE
    result = scanner.tokenize code
    expect(result[0]).to eq([:COMMENT_BEGIN, "/*"])
    expect(result[1]).to eq([:COMMENT, " This is a comment "])
    expect(result[2]).to eq([:COMMENT_END, "*/"])
  end

  it 'tokenizes the following keywords (if, else, true, false, nil)' do
    result = scanner.tokenize("if else true false nil")
    expect(result[0]).to eq([:IF, "if"])
    expect(result[1]).to eq([:ELSE, "else"])
    expect(result[2]).to eq([:TRUE, "true"])
    expect(result[3]).to eq([:FALSE, "false"])
    expect(result[4]).to eq([:NIL, "nil"])
  end

  it 'tokenizes an identifier' do
    result = scanner.tokenize("print")
    expect(result[0]).to eq([:IDENTIFIER, "print"])
  end

  it 'tokenizes an identifier even if a keyword (if) is within the text of the identifier' do
    result = scanner.tokenize("identifier")
    expect(result[0]).to eq([:IDENTIFIER, "identifier"])
  end

  it 'tokenizes a constant' do
    result = scanner.tokenize("MY_CONSTANT")
    expect(result[0]).to eq([:CONSTANT, "MY_CONSTANT"])
  end

  it 'tokenizes a float' do
    result = scanner.tokenize("30.00")
    expect(result[0]).to eq([:FLOAT, 30.0])
  end

  it 'tokenizes a negative float' do
    result = scanner.tokenize("-25.0")
    expect(result[0]).to eq([:FLOAT, -25.0])
  end

  it 'tokenizes an integer' do
    result = scanner.tokenize("3000")
    expect(result[0]).to eq([:INTEGER, 3000])
  end

  it 'tokenizes a negative integer' do
    result = scanner.tokenize("-5")
    expect(result[0]).to eq([:INTEGER, -5])
  end

  it 'tokenizes a symbol' do
    result = scanner.tokenize(":PAGE")
    expect(result[0]).to eq([:SYMBOL, ":PAGE"])
  end

  it 'tokenizes a string' do
    result = scanner.tokenize("\"hello\"")
    expect(result[0]).to eq([:STRING, "\"hello\""])
  end

  it 'tokenizes a number and a string' do
    result = scanner.tokenize("\"hello\" 3000")
    expect(result[0]).to eq([:STRING, "\"hello\""])
    expect(result[1]).to eq([:INTEGER, 3000])
  end

  it 'tokenizes a simple if/else block' do
    code = <<CODE
if test == "test":
  print "true"
else:
  print "false"
CODE
    result = scanner.tokenize(code)
    expect(result[0]).to eq([:IF, "if"])
    expect(result[1]).to eq([:IDENTIFIER, "test"])
    expect(result[2]).to eq([:OPERATOR, "=="])
    expect(result[3]).to eq([:STRING, "\"test\""])
    expect(result[4]).to eq([:VALUE, ":"])
    expect(result[5]).to eq([:INDENT, 2])
    expect(result[6]).to eq([:IDENTIFIER, "print"])
    expect(result[7]).to eq([:STRING, "\"true\""])
    expect(result[8]).to eq([:OUTDENT, 0])
    expect(result[9]).to eq([:ELSE, "else"])
    expect(result[10]).to eq([:VALUE, ":"])
    expect(result[11]).to eq([:INDENT, 2])
    expect(result[12]).to eq([:IDENTIFIER, "print"])
    expect(result[13]).to eq([:STRING, "\"false\""])
  end

  it 'tokenizes a calculation' do
    result = scanner.tokenize("5 + 20")
    expect(result[0]).to eq([:INTEGER, 5])
    expect(result[1]).to eq([:OPERATOR, "+"])
    expect(result[2]).to eq([:INTEGER, 20])
 end

  it 'tokenizes an identifier and ignores the newline' do
    code = <<CODE
print

CODE
    result = scanner.tokenize(code)
    expect(result[0]).to eq([:IDENTIFIER, "print"])
  end

  it 'tokenizes a simple function block' do
    code = <<CODE
function my_function:
  if true
    print "true"
CODE
    result = scanner.tokenize(code)
    expect(result[0]).to eq([:FUNCTION, "function"])
    expect(result[1]).to eq([:IDENTIFIER, "my_function"])
    expect(result[2]).to eq([:VALUE, ":"])
    expect(result[3]).to eq([:INDENT, 2])
    expect(result[4]).to eq([:IF, "if"])
    expect(result[5]).to eq([:TRUE, "true"])
    expect(result[6]).to eq([:INDENT, 4])
    expect(result[7]).to eq([:IDENTIFIER, "print"])
    expect(result[8]).to eq([:STRING, "\"true\""])
  end
end
