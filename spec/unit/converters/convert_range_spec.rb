# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, 'convert range' do

  subject(:prompt) { TTY::TestPrompt.new}

  it 'converts with valid range' do
    prompt.input << "20-30"
    prompt.input.rewind
    answer = prompt.ask("Which age group?", convert: :range)
    expect(answer).to be_a(Range)
    expect(answer).to eq(20..30)
  end

  it "fails to convert to range" do
    prompt.input << "abcd"
    prompt.input.rewind
    expect {
      prompt.ask('Which age group?', convert: :range)
    }.to raise_error(TTY::Prompt::ConversionError)
  end
end
