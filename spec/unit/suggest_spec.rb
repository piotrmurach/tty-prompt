# frozen_string_literal: true

RSpec.describe TTY::Prompt, '#suggest' do
  let(:possible) { %w(status stage stash commit branch blame) }

  subject(:prompt) { TTY::TestPrompt.new }

  it 'suggests few matches' do
    prompt.suggest('sta', possible)
    expect(prompt.output.string).
      to eql("Did you mean one of these?\n        stage\n        stash\n")
  end

  it 'suggests a single match for one character' do
    prompt.suggest('b', possible)
    expect(prompt.output.string).to eql("Did you mean this?\n        blame\n")
  end

  it 'suggests a single match for two characters' do
    prompt.suggest('co', possible)
    expect(prompt.output.string).to eql("Did you mean this?\n        commit\n")
  end

  it 'suggests with different text and indentation' do
    prompt.suggest('b', possible, indent: 4, single_text: 'Perhaps you meant?')
    expect(prompt.output.string).to eql("Perhaps you meant?\n    blame\n")
  end
end
