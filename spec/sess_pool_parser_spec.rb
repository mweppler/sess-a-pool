require 'spec_helper'

describe SessPoolParser do
  let(:parser) { SessPoolParser.new }

  it 'parses a number' do
    code = <<~CODE
      1
    CODE
    nodes = Nodes.new([
      NumberNode.new(1)
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses a string' do
    code = <<~CODE
      "hi"
    CODE
    nodes = Nodes.new([
      StringNode.new('hi')
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses an expression' do
    code = <<~CODE
      1
      "hi"
    CODE
    nodes = Nodes.new([
      NumberNode.new(1), StringNode.new('hi')
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses a call' do
    code = <<~CODE
      1.method
    CODE
    nodes = Nodes.new([
      CallNode.new(NumberNode.new(1), 'method', [])
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses a call with arguments' do
    code = <<~CODE
      method(1, 2)
    CODE
    nodes = Nodes.new([
      CallNode.new(nil, 'method', [NumberNode.new(1), NumberNode.new(2)])
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses an variable assignment' do
    code = <<~CODE
      a = 1
    CODE
    nodes = Nodes.new([
      SetLocalNode.new('a', NumberNode.new(1))
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses an constant assignment' do
    code = <<~CODE
      A = 1
    CODE
    nodes = Nodes.new([
      SetConstantNode.new('A', NumberNode.new(1))
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses a function' do
    code = <<~CODE
      def method:
        true
    CODE
    nodes = Nodes.new([
      DefNode.new('method', [],
        Nodes.new([TrueNode.new])
      )
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses a function with parameters' do
    code = <<~CODE
      def method(a, b):
        true
    CODE
    nodes = Nodes.new([
      DefNode.new('method', ['a', 'b'],
        Nodes.new([TrueNode.new])
      )
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses a class' do
    code = <<~CODE
      class ChunkyBacon:
        true
    CODE
    nodes = Nodes.new([
      ClassNode.new('ChunkyBacon',
        Nodes.new([TrueNode.new])
      )
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses simple arithmetic' do
    code = <<~CODE
      1 + 2 * 3
    CODE
    nodes = Nodes.new([
      CallNode.new(NumberNode.new(1), '+', [
        CallNode.new(NumberNode.new(2), '*', [NumberNode.new(3)])
      ])
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses more complex arithmetic' do
    code = <<~CODE
      1 + (2 * 3)
    CODE
    nodes = Nodes.new([
      CallNode.new(NumberNode.new(1), '+', [
        CallNode.new(NumberNode.new(2), '*', [NumberNode.new(3)])
      ])
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses binary operator/operation' do
    code = <<~CODE
      1 + 2 || 3
    CODE
    nodes = Nodes.new([
      CallNode.new(
        CallNode.new(NumberNode.new(1), '+', [NumberNode.new(2)]),
        '||',
        [NumberNode.new(3)]
      )
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses an if statement' do
    code = <<~CODE
      if true:
        nil
    CODE
    nodes = Nodes.new([
      IfNode.new(TrueNode.new,
        Nodes.new([NilNode.new])
      )
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses a while statement' do
    code = <<~CODE
      while false:
        print "true"
    CODE
    nodes = Nodes.new([
      WhileNode.new(
        FalseNode.new,
        Nodes.new([
          CallNode.new(nil, 'print', [StringNode.new('true')])
        ])
      )
    ])
    expect(parser.parse(code)).to eq nodes
  end

  it 'parses a unary (!) operator' do
    code = <<~CODE
      !2
    CODE
    nodes = Nodes.new([
      CallNode.new(NumberNode.new(2), '!', [])
    ])
    expect(parser.parse(code)).to eq nodes
  end
end

