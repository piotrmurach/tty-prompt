# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, 'convert string' do
  it 'converts string' do
    prompt = TTY::TestPrompt.new
    prompt.input << 'Piotr'
    prompt.input.rewind
    answer = prompt.ask("What is your name?", convert: :string)
    expect(answer).to be_a(String)
    expect(answer).to eq('Piotr')
  end

  it "converts symbol" do
    prompt = TTY::TestPrompt.new
    prompt.input << 'Piotr'
    prompt.input.rewind
    answer = prompt.ask("What is your name?", convert: :symbol)
    expect(answer).to be_a(Symbol)
    expect(answer).to eq(:Piotr)
  end
end
