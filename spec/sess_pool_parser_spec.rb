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

end
