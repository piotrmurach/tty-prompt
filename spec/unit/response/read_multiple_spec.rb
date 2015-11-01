# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#read_multiple' do
  let(:input)  { StringIO.new }
  let(:output) { StringIO.new }
  let(:prompt) { TTY::Prompt.new(input, output) }

  it 'reads multiple lines' do
    input << "First line\nSecond line\nThird line"
    input.rewind
    q = prompt.ask("Provide description?")
    expect(q.read_multiple).to eq("First line\nSecond line\nThird line")
  end

  it 'terminates on empty lines' do
    input << "First line\n\nSecond line"
    input.rewind
    q = prompt.ask("Provide description?")
    expect(q.read_multiple).to eq("First line\n")
  end
end
