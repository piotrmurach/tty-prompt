# encoding: utf-8

RSpec.describe TTY::Prompt::Question, 'ask keypress' do
  it 'asks for a keypress with :read option' do
    prompt = TTY::TestPrompt.new
    prompt.input << "abcd"
    prompt.input.rewind
    answer = prompt.ask("Which one do you prefer a, b, c or d?", read: :keypress)
    expect(answer).to eq("a")
  end

  it 'asks for a keypress with method' do
    prompt = TTY::TestPrompt.new
    prompt.input << "abcd"
    prompt.input.rewind
    answer = prompt.ask_keypress("Which one do you prefer a, b, c or d?")
    expect(answer).to eq("a")
  end
end
