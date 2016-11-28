# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#validate' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'validates input with regex' do
    prompt.input << 'piotr.murach'
    prompt.input.rewind

    answer = prompt.ask('What is your username?') do |q|
      q.validate(/^[^\.]+\.[^\.]+/)
    end

    expect(answer).to eq('piotr.murach')
    expect(prompt.output.string).to eq([
      "What is your username? ",
      "\e[1000D\e[K\e[1A",
      "\e[1000D\e[K",
      "What is your username? \e[32mpiotr.murach\e[0m\n"
    ].join)
  end

  it 'validates input with proc' do
    prompt.input << 'piotr.murach'
    prompt.input.rewind

    answer = prompt.ask('What is your username?') do |q|
      q.validate { |input| input =~ /^[^\.]+\.[^\.]+/ }
    end

    expect(answer).to eq('piotr.murach')
  end

  it 'understands custom validation like :email' do
    prompt.input << 'piotr@example.com'
    prompt.input.rewind

    answer = prompt.ask('What is your email?') do |q|
      q.validate :email
    end

    expect(answer).to eq('piotr@example.com')
  end

  it "provides default error message for wrong input" do
    prompt.input << "invalid\npiotr@example.com"
    prompt.input.rewind

    answer = prompt.ask('What is your email?') do |q|
      q.validate :email
    end

    expect(answer).to eq('piotr@example.com')
    expect(prompt.output.string).to eq([
      "What is your email? ",
      "\e[1000D\e[K",
      "\e[31m>>\e[0m Your answer is invalid (must match :email)\e[1A",
      "\e[1000D\e[K",
      "What is your email? ",
      "\e[1000D\e[K\e[1A",
      "\e[1000D\e[K",
      "What is your email? \e[32mpiotr@example.com\e[0m\n"
    ].join)
  end

  it "provides custom error message for wrong input" do
    prompt.input << "invalid\npiotr@example.com"
    prompt.input.rewind

    answer = prompt.ask('What is your email?') do |q|
      q.validate :email
      q.messages[:valid?] = 'Not an email!'
    end

    expect(answer).to eq('piotr@example.com')
    expect(prompt.output.string).to eq([
      "What is your email? ",
      "\e[1000D\e[K",
      "\e[31m>>\e[0m Not an email!\e[1A",
      "\e[1000D\e[K",
      "What is your email? ",
      "\e[1000D\e[K\e[1A",
      "\e[1000D\e[K",
      "What is your email? \e[32mpiotr@example.com\e[0m\n"
    ].join)
  end
end
