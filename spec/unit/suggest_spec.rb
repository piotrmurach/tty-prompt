# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt, '#suggest' do
  let(:input)  { StringIO.new }
  let(:output) { StringIO.new }
  let(:possible) { %w(status stage stash commit branch blame) }

  subject(:prompt) { described_class.new(input, output) }

  after { output.rewind }

  it 'suggests few matches' do
    prompt.suggest('sta', possible)
    expect(output.string).to eql("Did you mean one of these?\n        stage\n        stash\n")
  end

  it 'suggests a single match for one character' do
    prompt.suggest('b', possible)
    expect(output.string).to eql("Did you mean this?\n        blame\n")
  end

  it 'suggests a single match for two characters' do
    prompt.suggest('co', possible)
    expect(output.string).to eql("Did you mean this?\n        commit\n")
  end

  it 'suggests with different text and indentation' do
    prompt.suggest('b', possible, indent: 4, single_text: 'Perhaps you meant?')
    expect(output.string).to eql("Perhaps you meant?\n    blame\n")
  end
end
