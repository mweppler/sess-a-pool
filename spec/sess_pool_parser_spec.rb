require 'spec_helper'

describe SessPoolParser do
  let(:parser) { SessPoolParser.new }

  it 'parses a number' do
    expect(parser.parse(%{1})).to eq(Nodes.new([NumberNode.new(1)]))
  end

  it 'parses a string' do
    expect(parser.parse(%{"hi"})).to eq(Nodes.new([StringNode.new("hi")]))
  end

  it 'parses an expression' do
    expect(parser.parse(%{1\n"hi"})).to eq(Nodes.new([NumberNode.new(1), StringNode.new("hi")]))
  end

  it 'parses a call' do
    nodes = Nodes.new([CallNode.new(NumberNode.new(1), "method", [])])
    expect(parser.parse("1.method")).to eq(nodes)
  end

  it 'parses a call with arguments' do
    nodes = Nodes.new([CallNode.new(nil, "method", [NumberNode.new(1), NumberNode.new(2)])])
    expect(parser.parse("method(1, 2)")).to eq(nodes)
  end

  it 'parses an assignment' do
    expect(parser.parse("a = 1")).to eq(Nodes.new([SetLocalNode.new("a", NumberNode.new(1))]))
    expect(parser.parse("A = 1")).to eq(Nodes.new([SetConstantNode.new("A", NumberNode.new(1))]))
  end

  it 'parses a function' do
    code = <<CODE
def method:
  true
CODE

    nodes = Nodes.new([
      DefNode.new("method", [],
        Nodes.new([TrueNode.new])
      )
    ])

    expect(parser.parse(code)).to eq nodes
  end

  it 'parses a function with parameters' do
    code = <<CODE
def method(a, b):
  true
CODE

    nodes = Nodes.new([
      DefNode.new("method", ["a", "b"],
        Nodes.new([TrueNode.new])
      )
    ])

    expect(parser.parse(code)).to eq nodes
  end

  it 'parses a class' do
    code = <<CODE
class ChunkyBacon:
  true
CODE

    nodes = Nodes.new([
      ClassNode.new("ChunkyBacon",
        Nodes.new([TrueNode.new])
      )
    ])

    expect(parser.parse(code)).to eq nodes
  end

  it 'parses arithmetic' do
    nodes = Nodes.new([
      CallNode.new(NumberNode.new(1), "+", [
        CallNode.new(NumberNode.new(2), "*", [NumberNode.new(3)])
      ])
    ])

    expect(parser.parse("1 + 2 * 3")).to eq nodes
    expect(parser.parse("1 + (2 * 3)")).to eq nodes
  end

  it 'parses binary operator/operation' do
    nodes = Nodes.new([
      CallNode.new(
        CallNode.new(NumberNode.new(1), "+", [NumberNode.new(2)]),
        "||",
        [NumberNode.new(3)]
      )
    ])

    expect(parser.parse("1 + 2 || 3")).to eq nodes
  end

  it 'parses an if statement' do
    code = <<CODE
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

  it 'parses a unary (!) operator' do
    nodes = Nodes.new([
      CallNode.new(NumberNode.new(2), "!", [])
    ])

    expect(parser.parse("!2")).to eq nodes
  end
end
