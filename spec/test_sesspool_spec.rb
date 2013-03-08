require './sess_pool_scanner'

class TestSessPool

  describe 'Testing the Sess Pool Scanner' do
    before do
      @scanner = SessPoolScanner.new
    end

    it 'tests for an if' do
      result = @scanner.tokenize("if")
      result[0][0].should == :IF
      result[0][1].should == "if"
    end

    it 'tests for an if statement' do
      code = <<CODE
if 5 > 6 print "five is greater than six"
CODE
      result = @scanner.tokenize(code)
      result[0][0].should == :IF
      result[0][1].should == "if"
      result[1][0].should == :INTEGER
      result[1][1].should == 5
      result[2][0].should == :GREATER_THAN
      result[2][1].should == ">"
      result[3][0].should == :INTEGER
      result[3][1].should == 6
      result[4][0].should == :IDENTIFIER
      result[4][1].should == "print"
      result[5][0].should == :STRING
      result[5][1].should == "\"five is greater than six\""
    end

    it 'tests for an integer' do
      result = @scanner.tokenize("3000")
      result[0][0].should == :INTEGER
      result[0][1].should == 3000
    end

    it 'tests for an identifier' do
      code = <<CODE
print
CODE
      result = @scanner.tokenize(code)
      result[0][0].should == :IDENTIFIER
      result[0][1].should == "print"
    end

    it 'tests for a constant' do
      result = @scanner.tokenize("MY_CONSTANT")
      result[0][0].should == :CONSTANT
      result[0][1].should == "MY_CONSTANT"
    end

    it 'tests for a symbol' do
      result = @scanner.tokenize(":page")
      result[0][0].should == :SYMBOL
      result[0][1].should == ":page"
    end

    it 'tests for a string' do
      code = <<CODE
"hello"
CODE
      result = @scanner.tokenize(code)
      result[0][0].should == :STRING
      result[0][1].should == "\"hello\""
    end

    it 'tests for a number and a string' do
      code = <<CODE
"hello" 3000
CODE
      result = @scanner.tokenize(code)
      result[0][0].should == :STRING
      result[0][1].should == "\"hello\""
      result[1][0].should == :INTEGER
      result[1][1].should == 3000
    end

  end
end
