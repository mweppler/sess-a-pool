require './sess_pool_scanner'

describe SessPoolScanner do
  let(:scanner) { SessPoolScanner.new }

  it 'tokenizes the following keywords (if, else, true, false, nil)' do
    result = scanner.tokenize("if else true false nil")
    result[0][0].should == :IF
    result[0][1].should == "if"
    result[1][0].should == :ELSE
    result[1][1].should == "else"
    result[2][0].should == :TRUE
    result[2][1].should == "true"
    result[3][0].should == :FALSE
    result[3][1].should == "false"
    result[4][0].should == :NIL
    result[4][1].should == "nil"
  end

  it 'tokenizes an identifier' do
    result = scanner.tokenize("print")
    result[0][0].should == :IDENTIFIER
    result[0][1].should == "print"
  end

  it 'tokenizes an identifier even if a keyword (if) is within the text of the identifier' do
    result = scanner.tokenize("identifier")
    result[0][0].should == :IDENTIFIER
    result[0][1].should == "identifier"
  end

  it 'tokenizes a constant' do
    result = scanner.tokenize("MY_CONSTANT")
    result[0][0].should == :CONSTANT
    result[0][1].should == "MY_CONSTANT"
  end

  it 'tokenizes a float' do
    result = scanner.tokenize("30.00")
    result[0][0].should == :FLOAT
    result[0][1].should == 30.0
  end

  it 'tokenizes a negative float' do
    result = scanner.tokenize("-25.0")
    result[0][0].should == :FLOAT
    result[0][1].should == -25.0
  end

  it 'tokenizes an integer' do
    result = scanner.tokenize("3000")
    result[0][0].should == :INTEGER
    result[0][1].should == 3000
  end

  it 'tokenizes a negative integer' do
    result = scanner.tokenize("-5")
    result[0][0].should == :INTEGER
    result[0][1].should == -5
  end

  it 'tokenizes a symbol' do
    result = scanner.tokenize(":PAGE")
    result[0][0].should == :SYMBOL
    result[0][1].should == ":PAGE"
  end

  it 'tokenizes a string' do
    result = scanner.tokenize("\"hello\"")
    result[0][0].should == :STRING
    result[0][1].should == "\"hello\""
  end

  it 'tokenizes a number and a string' do
    result = scanner.tokenize("\"hello\" 3000")
    result[0][0].should == :STRING
    result[0][1].should == "\"hello\""
    result[1][0].should == :INTEGER
    result[1][1].should == 3000
  end

  it 'tokenizes a simple if/else block' do
    code = <<CODE
if test == "test":
  print "true"
else:
  print "false"
CODE
    result = scanner.tokenize(code)
    result[0][0].should == :IF
    result[0][1].should == "if"
    result[1][0].should == :IDENTIFIER
    result[1][1].should == "test"
    result[2][0].should == :OPERATOR
    result[2][1].should == "=="
    result[3][0].should == :STRING
    result[3][1].should == "\"test\""
    result[4][0].should == :VALUE
    result[4][1].should == ":"
    result[5][0].should == :INDENT
    result[5][1].should == 2
    result[6][0].should == :IDENTIFIER
    result[6][1].should == "print"
    result[7][0].should == :STRING
    result[7][1].should == "\"true\""
    result[8][0].should == :ELSE
    result[8][1].should == "else"
    result[9][0].should == :VALUE
    result[9][1].should == ":"
    result[10][0].should == :INDENT
    result[10][1].should == 2
    result[11][0].should == :IDENTIFIER
    result[11][1].should == "print"
    result[12][0].should == :STRING
    result[12][1].should == "\"false\""
  end

  it 'tokenizes a calculation' do
    result = scanner.tokenize("5 + 20")
    result[0][0].should == :INTEGER
    result[0][1].should == 5
    result[1][0].should == :OPERATOR
    result[1][1].should == "+"
    result[2][0].should == :INTEGER
    result[2][1].should == 20
 end

  it 'tokenizes an identifier and a newline' do
    code = <<CODE
print

CODE
    result = scanner.tokenize(code)
    result[0][0].should == :IDENTIFIER
    result[0][1].should == "print"
    # result[1][0].should == :INDENT
    # result[1][1].should == 0
  end

  it 'tokenizes a simple function block' do
    code = <<CODE
function my_function:
  if true
    print "true"
CODE
    result = scanner.tokenize(code)
    result[0][0].should == :FUNCTION
    result[0][1].should == "function"
    result[1][0].should == :IDENTIFIER
    result[1][1].should == "my_function"
    result[2][0].should == :VALUE
    result[2][1].should == ":"
    result[3][0].should == :INDENT
    result[3][1].should == 2
    result[4][0].should == :IF
    result[4][1].should == "if"
    result[5][0].should == :TRUE
    result[5][1].should == "true"
    result[6][0].should == :INDENT
    result[6][1].should == 4
    result[7][0].should == :IDENTIFIER
    result[7][1].should == "print"
    result[8][0].should == :STRING
    result[8][1].should == "\"true\""
  end
end
