# encoding: utf-8

RSpec.describe TTY::Prompt::Question, 'convert range' do
  it 'converts with valid range' do
    prompt = TTY::TestPrompt.new
    prompt.input << "20-30"
    prompt.input.rewind
    answer = prompt.ask("Which age group?", convert: :range)
    expect(answer).to be_a(Range)
    expect(answer).to eq(20..30)
  end

  it "fails to convert to range" do
    prompt = TTY::TestPrompt.new
    prompt.input << "abcd"
    prompt.input.rewind
    expect {
      prompt.ask('Which age group?', convert: :range)
    }.to raise_error(Necromancer::ConversionTypeError)
  end
end
