# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#required' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'requires value to be present' do
    prompt.input << "Piotr"
    prompt.input.rewind
    prompt.ask('What is your name?') { |q| q.required(true) }
    expect(prompt.output.string).to eq([
      "What is your name? ",
      "\e[1A\e[1000D\e[K",
      "What is your name? \e[32mPiotr\e[0m"
    ].join)
  end

  it 'requires value to be present with option' do
    prompt.input << "Piotr"
    prompt.input.rewind
    prompt.ask('What is your name?') { |q| q.required(true) }
    expect(prompt.output.string).to eq([
      "What is your name? ",
      "\e[1A\e[1000D\e[K",
      "What is your name? \e[32mPiotr\e[0m"
    ].join)
  end

  it "doesn't require value to be present" do
    prompt.input << ''
    prompt.input.rewind
    answer = prompt.ask('What is your name?') { |q| q.required(false) }
    expect(answer).to be_nil
  end
end
