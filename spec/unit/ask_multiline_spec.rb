# encoding: utf-8

RSpec.describe TTY::Prompt::Question, 'read multiline' do
  it 'reads multiple lines' do
    prompt = TTY::TestPrompt.new
    prompt.input << "First line\nSecond line\nThird line"
    prompt.input.rewind
    answer = prompt.ask("Provide description?", read: :multiline)
    expect(answer).to eq(['First line', 'Second line', 'Third line'])
  end

  it 'terminates on empty lines' do
    prompt = TTY::TestPrompt.new
    prompt.input << "First line\n\nSecond line"
    prompt.input.rewind
    answer = prompt.ask("Provide description?")
    expect(answer).to eq("First line")
  end
end
