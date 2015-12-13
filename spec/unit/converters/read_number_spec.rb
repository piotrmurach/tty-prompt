# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#read_numbers' do
  it 'reads integer' do
    prompt = TTY::TestPrompt.new
    prompt.input << 35
    prompt.input.rewind
    answer = prompt.ask("What temperature?", read: :int)
    expect(answer).to be_a(Integer)
    expect(answer).to eq(35)
  end

  it 'reads float' do
    prompt = TTY::TestPrompt.new
    number = 6.666
    prompt.input << number
    prompt.input.rewind
    answer = prompt.ask('How tall are you?', read: :float)
    expect(answer).to be_a(Float)
    expect(answer).to eq(number)
  end
end
