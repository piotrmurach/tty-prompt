# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#character' do
  it 'switches to character input' do
    prompt = TTY::TestPrompt.new
    prompt.input << "abcd"
    prompt.input.rewind
    answer = prompt.ask("Which one do you prefer a, b, c or d?") { |q| q.char(true) }
    expect(answer).to eq("a")
  end
end
