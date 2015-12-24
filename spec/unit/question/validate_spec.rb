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
      "What is your username? piotr.murach",
      "\e[1A\e[1000D\e[K",
      "What is your username? \e[32mpiotr.murach\e[0m"
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
end
