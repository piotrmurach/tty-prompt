# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, 'convert numbers' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'fails to convert integer' do
    prompt.input << 'invalid'
    prompt.input.rewind
    expect {
      prompt.ask("What temparture?", convert: :int)
    }.to raise_error(TTY::Prompt::ConversionError)
  end

  it 'converts integer' do
    prompt.input << 35
    prompt.input.rewind
    answer = prompt.ask("What temperature?", convert: :int)
    expect(answer).to be_a(Integer)
    expect(answer).to eq(35)
  end

  it 'fails to convert float' do
    prompt.input << 'invalid'
    prompt.input.rewind
    expect {
      prompt.ask("How tall are you?", convert: :float)
    }.to raise_error(TTY::Prompt::ConversionError)
  end

  it 'converts float' do
    number = 6.666
    prompt.input << number
    prompt.input.rewind
    answer = prompt.ask('How tall are you?', convert: :float)
    expect(answer).to be_a(Float)
    expect(answer).to eq(number)
  end
end
