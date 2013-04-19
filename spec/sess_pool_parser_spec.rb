require 'spec_helper'

describe SessPoolParser do
  let(:parser) { SessPoolParser.new }

  it 'parses a number' do
    expect(parser.parse('1')).to eq(Nodes.new([NumberNode.new(1)]))
  end

  it 'parses a string' do
    expect(parser.parse(%{"hi"})).to eq(Nodes.new([StringNode.new("hi")]))
  end
end

