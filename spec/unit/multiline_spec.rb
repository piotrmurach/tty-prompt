# encoding: utf-8

RSpec.describe TTY::Prompt::Question, 'ask multiline' do
  it 'reads multiple lines with :read option' do
    prompt = TTY::TestPrompt.new
    prompt.input << "First line\nSecond line\nThird line"
    prompt.input.rewind
    answer = prompt.ask("Provide description?", read: :multiline)
    expect(answer).to eq(['First line', 'Second line', 'Third line'])
  end

  it 'reads multiple lines with method' do
    prompt = TTY::TestPrompt.new
    prompt.input << "First\nSecond\nThird"
    prompt.input.rewind
    answer = prompt.multiline("Provide description?")
    expect(answer).to eq(['First', 'Second', 'Third'])
  end
end
