# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#validate' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'validates input with regex' do
    prompt.input << 'p.m'
    prompt.input.rewind

    answer = prompt.ask('What is your username?') do |q|
      q.validate(/^[^\.]+\.[^\.]+/)
    end

    expect(answer).to eq('p.m')
    expect(prompt.output.string).to eq([
      "What is your username? ",
      "\e[2K\e[1GWhat is your username? p",
      "\e[2K\e[1GWhat is your username? p.",
      "\e[2K\e[1GWhat is your username? p.m",
      "\e[1A\e[2K\e[1G",
      "What is your username? \e[32mp.m\e[0m\n"
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
    prompt.input << "wrong\np@m.com\n"
    prompt.input.rewind

    answer = prompt.ask('What is your email?') do |q|
      q.validate :email
    end

    expect(answer).to eq('p@m.com')
    expect(prompt.output.string).to eq([
      "What is your email? ",
      "\e[2K\e[1GWhat is your email? w",
      "\e[2K\e[1GWhat is your email? wr",
      "\e[2K\e[1GWhat is your email? wro",
      "\e[2K\e[1GWhat is your email? wron",
      "\e[2K\e[1GWhat is your email? wrong",
      "\e[2K\e[1GWhat is your email? wrong\n",
      "\e[31m>>\e[0m Your answer is invalid (must match :email)\e[1A",
      "\e[2K\e[1G",
      "What is your email? ",
      "\e[2K\e[1GWhat is your email? p",
      "\e[2K\e[1GWhat is your email? p@",
      "\e[2K\e[1GWhat is your email? p@m",
      "\e[2K\e[1GWhat is your email? p@m.",
      "\e[2K\e[1GWhat is your email? p@m.c",
      "\e[2K\e[1GWhat is your email? p@m.co",
      "\e[2K\e[1GWhat is your email? p@m.com",
      "\e[2K\e[1GWhat is your email? p@m.com\n",
      "\e[2K\e[1G",
      "\e[1A\e[2K\e[1G",
      "What is your email? \e[32mp@m.com\e[0m\n"
    ].join)
  end

  it "provides custom error message for wrong input" do
    prompt.input << "wrong\np@m.com"
    prompt.input.rewind

    answer = prompt.ask('What is your email?') do |q|
      q.validate :email
      q.messages[:valid?] = 'Not an email!'
    end

    expect(answer).to eq('p@m.com')
    expect(prompt.output.string).to eq([
      "What is your email? ",
      "\e[2K\e[1GWhat is your email? w",
      "\e[2K\e[1GWhat is your email? wr",
      "\e[2K\e[1GWhat is your email? wro",
      "\e[2K\e[1GWhat is your email? wron",
      "\e[2K\e[1GWhat is your email? wrong",
      "\e[2K\e[1GWhat is your email? wrong\n",
      "\e[31m>>\e[0m Not an email!\e[1A",
      "\e[2K\e[1G",
      "What is your email? ",
      "\e[2K\e[1GWhat is your email? p",
      "\e[2K\e[1GWhat is your email? p@",
      "\e[2K\e[1GWhat is your email? p@m",
      "\e[2K\e[1GWhat is your email? p@m.",
      "\e[2K\e[1GWhat is your email? p@m.c",
      "\e[2K\e[1GWhat is your email? p@m.co",
      "\e[2K\e[1GWhat is your email? p@m.com",
      "\e[2K\e[1G",
      "\e[1A\e[2K\e[1G",
      "What is your email? \e[32mp@m.com\e[0m\n"
    ].join)
  end
end
