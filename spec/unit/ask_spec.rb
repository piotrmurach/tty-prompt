# encoding: utf-8

RSpec.describe TTY::Prompt, '#ask' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'asks question' do
    prompt.ask('What is your name?')
    expect(prompt.output.string).to eq([
      "What is your name? ",
      "\e[1000D\e[K\e[1A",
      "\e[1000D\e[K",
      "What is your name? \n"
    ].join)
  end

  it 'asks an empty question ' do
    prompt.ask('')
    expect(prompt.output.string).to eql('')
  end

  it 'asks an empty question and returns nil if EOF is sent to stdin' do
    prompt.input << nil
    prompt.input.rewind
    answer = prompt.ask('')
    expect(answer).to eql(nil)
    expect(prompt.output.string).to eq('')
  end

  it "asks a question with a prefix [?]" do
    prompt = TTY::TestPrompt.new(prefix: "[?] ")
    prompt.input << "\r"
    prompt.input.rewind
    answer = prompt.ask 'Are you Polish?'
    expect(answer).to eq(nil)
    expect(prompt.output.string).to eq([
      "[?] Are you Polish? ",
      "\e[1000D\e[K\e[1A",
      "\e[1000D\e[K",
      "[?] Are you Polish? \n"
    ].join)
  end

  it 'asks a question with block' do
    prompt.input << ''
    prompt.input.rewind
    answer = prompt.ask "What is your name?" do |q|
      q.default 'Piotr'
    end
    expect(answer).to eq('Piotr')
    expect(prompt.output.string).to eq([
      "What is your name? \e[90m(Piotr)\e[0m ",
      "\e[1000D\e[K\e[1A",
      "\e[1000D\e[K",
      "What is your name? \e[32mPiotr\e[0m\n"
    ].join)
  end

  it "permits empty default parameter" do
    prompt.input << "\r"
    prompt.input.rewind

    answer = prompt.ask("What is your name?", default: '')
    expect(answer).to eq('')
    expect(prompt.output.string).to eq([
      "What is your name? ",
      "\e[1000D\e[K\e[1A",
      "\e[1000D\e[K",
      "What is your name? \n"
    ].join)
  end

  it "permits nil default parameter" do
    prompt.input << "\r"
    prompt.input.rewind

    answer = prompt.ask("What is your name?", default: nil)
    expect(answer).to eq(nil)
    expect(prompt.output.string).to eq([
      "What is your name? ",
      "\e[1000D\e[K\e[1A",
      "\e[1000D\e[K",
      "What is your name? \n"
    ].join)
  end
end
