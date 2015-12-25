# encoding: utf-8

RSpec.describe TTY::Prompt::Question, 'convert numbers' do
  it 'converts integer' do
    prompt = TTY::TestPrompt.new
    prompt.input << 35
    prompt.input.rewind
    answer = prompt.ask("What temperature?", convert: :int)
    expect(answer).to be_a(Integer)
    expect(answer).to eq(35)
  end

  it 'converts float' do
    prompt = TTY::TestPrompt.new
    number = 6.666
    prompt.input << number
    prompt.input.rewind
    answer = prompt.ask('How tall are you?', convert: :float)
    expect(answer).to be_a(Float)
    expect(answer).to eq(number)
  end
end
