# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#multiline' do
  it 'reads no lines' do
    prompt = TTY::TestPrompt.new
    prompt.input << "\n"
    prompt.input.rewind
    answer = prompt.multiline("Provide description?")
    expect(answer).to eq(nil)
  end

  it 'reads multiple lines with method' do
    prompt = TTY::TestPrompt.new
    prompt.input << "First line\nSecond line\nThird line"
    prompt.input.rewind
    answer = prompt.multiline("Provide description?")
    expect(answer).to eq(['First line', 'Second line', 'Third line'])
  end
end
